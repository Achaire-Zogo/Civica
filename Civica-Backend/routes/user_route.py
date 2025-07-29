#!/usr/bin/env python3
from email import message
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status,Request,BackgroundTasks
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from models.model_user import UserEntity, UserCreate, UserUpdate, UserResponse, UserLogin, UserRegister
from security.crypt import decrypt, encrypt
from firebase_admin import auth, firestore
from firebase_admin.auth import UserRecord
from security.password_utils import verify_password,get_password_hash
from datetime import datetime, timedelta
from security.token_utils import generate_token, verify_token
from fastapi_mail import FastMail, MessageSchema, MessageType,ConnectionConfig
import re
import random
import string
import os
from dotenv import load_dotenv
from models.model_verification_code import VerificationCodeEntity, VerificationCodeBase, VerificationCodeCreate, VerificationCodeUpdate, VerificationCodeResponse
from models.utils_model import CheckEmail,CheckEmailAndCode,UserChangePassword
load_dotenv()
# Importer les dépendances depuis le fichier dependencies.py
from dependencies import get_db, StandardResponse
import logging
import uuid

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/user",
    tags=["User"],
    responses={404: {"description": "Not found"}},
)

@router.get("/", response_model=StandardResponse)
def get_all_users(email: Optional[str] = None, db: Session = Depends(get_db)):
    """Liste toutes les utilisateurs ou recherche par email"""
    query = db.query(UserEntity)
    
    # Si un email est fourni, filtrer les résultats
    if email:
        query = query.filter(UserEntity.email.like(f'%{email}%'))
    
    users = query.all()
    user_list = [user.to_dict() for user in users]
    
    # Message personnalisé en fonction du type de recherche
    if email:
        message = f"Utilisateurs correspondant à '{email}' récupérés avec succès"
    else:
        message = "Liste des utilisateurs récupérée avec succès"
    
    return StandardResponse(
        statusCode=200,
        message=message,
        data={"users": user_list}
    )

@router.get("/{user_id}", response_model=StandardResponse)
def get_user(user_id: int, db: Session = Depends(get_db)):
    """Obtient un utilisateur par son ID"""

    decrypted_user_id = decrypt(user_id)
    try:
        user = db.query(UserEntity).filter(UserEntity.id == decrypted_user_id).first()
    except Exception as e:
        return StandardResponse(
            statusCode=500,
            message="Internal server error",
            data=None
        )
    if user is None:
        return StandardResponse(
            statusCode=404,
            message="user not found",
            data=None
        )
    return StandardResponse(
        statusCode=200,
        message="success retrieve user",
        data={"user": user.to_dict()}
    )

#check user by email
@router.get("/check-email/{email}", response_model=StandardResponse)
def check_user_by_email(email: str, db: Session = Depends(get_db)):
    """Check if a user exists by email"""
    
    try:
        decrypted_email = decrypt(email)
        user = db.query(UserEntity).filter(UserEntity.email == decrypted_email).first()
    except Exception as e:
        return StandardResponse(
            statusCode=500,
            message="Internal server error",
            data=None
        )
    if user is None:
        return StandardResponse(
            statusCode=404,
            message="user not found",
            data=None
        )
    return StandardResponse(
        statusCode=200,
        message="success retrieve user",
        data={"user": user.to_dict()}
    )



@router.post("/register")
async def register(user: UserRegister, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """Register a new user with improved error handling and logic"""
    
    firebase_user = None
    
    try:
        # 1. Decrypt user data
        decrypted_email = decrypt(user.email)
        decrypted_password = decrypt(user.password)
        decrypted_first_name = decrypt(user.first_name)
        decrypted_last_name = decrypt(user.last_name)
        decrypted_phonenumber = decrypt(user.phonenumber)
        
        # 2. Initialize Firebase
        initialize_firebase()
        firestore_db = firestore.client()
        # Check local database
        try:
            existing_user_email = db.query(UserEntity).filter(UserEntity.email == decrypted_email).first()
            if existing_user_email:
                logger.info(f"User with this email already exists local database: {decrypted_email}")
                return JSONResponse(
                    status_code=409,  # ✅ Correct status code
                    content={
                        "message": "User with this email already exists",
                        "error": "Email already in use local database"
                    }
                )
            
            existing_user_phone = db.query(UserEntity).filter(UserEntity.phonenumber == decrypted_phonenumber).first()
            if existing_user_phone:
                logger.info(f"User with this phone number already exists local database: {decrypted_phonenumber}")
                return JSONResponse(
                    status_code=409,  # ✅ Correct status code
                    content={
                        "message": "User with this phone number already exists",
                        "error": "Phone number already in use local database"
                    }
                )
        except Exception as e:
            logger.error(f"Local database check error: {str(e)}")
            return JSONResponse(
                status_code=500,
                content={
                    "message": "Internal server error",
                    "error": "Database service unavailable local database"
                }
            )
        
        # 4. Validate country exists
        country = db.query(CountryEntity).filter(CountryEntity.id == user.country_id).first()
        if not country:
            return JSONResponse(
                status_code=400,
                content={
                    "message": "Invalid country selected",
                    "error": "Country not found"
                }
            )

        # Create local database user
        hashed_password = get_password_hash(decrypted_password)
        # Check if user already exists in local database
        new_user = UserEntity(
        id=uuid.uuid4(),
            country_id=str(user.country_id),
            first_name=decrypted_first_name,
            last_name=decrypted_last_name,
            email=decrypted_email,
            phonenumber=decrypted_phonenumber,
            password=hashed_password,
            is_verified='NO',
            status='INACTIVE',
            connexion_type='EMAIL',
            role='USER'
        )
        
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        logger.info("Local database user created")
        
        # Send verification code (non-blocking)
        try:
            await create_and_send_verification_code(decrypted_email, background_tasks, db)
            logger.info(f"Verification code sent to: {decrypted_email}")
        except Exception as e:
            logger.error(f"Failed to send verification code: {str(e)}")
            # Don't fail registration for this
        
        # Prepare response
        user_dict = new_user.to_dict()
        if 'password' in user_dict:
            del user_dict['password']
        user_dict['country_name'] = country.name
        
        return JSONResponse(
            status_code=201,
            content={
                "message": "User registered successfully",
                "data": user_dict
            }
        )
            
    except Exception as creation_error:
        logger.error(f"User creation failed: {str(creation_error)}")
        db.rollback()
        
        error_str = str(creation_error).lower()
        if 'email-already-in-use' in error_str:
            error_message = "This email is already in use"
        elif 'invalid-email' in error_str:
            error_message = "Invalid email format"
        elif 'weak-password' in error_str:
            error_message = "Password is too weak (minimum 6 characters)"
        elif 'phone-already-in-use' in error_str or 'phonenumber already exists' in error_str:  # ✅ Fixed typo
            error_message = "This phone number is already in use"
        else:
            error_message = "Registration failed. Please try again."
        
        return JSONResponse(
            status_code=400,
            content={
                "message": error_message,
                "error": error_message
            }
        )
            
    except Exception as e:
        logger.error(f"Registration error: {str(e)}")
        db.rollback()
        
        return JSONResponse(
            status_code=500,
            content={
                "message": "An error occurred during registration",
                "error": "Internal server error"
            }
        )



@router.put("/{user_id}", response_model=StandardResponse)
def update_user(user_id: str, user: UserUpdate, db: Session = Depends(get_db)):
    """Met à jour un utilisateur existant"""
    try:
        db_user = db.query(UserEntity).filter(UserEntity.id == user_id).first()
        if db_user is None:
            return StandardResponse(
                statusCode=404,
                message="Utilisateur non trouvé",
                data=None
            )
        
        # Mettre à jour les champs
        if user.country_id is not None:
            db_user.country_id = user.country_id
        if user.first_name is not None:
            db_user.first_name = user.first_name
        if user.last_name is not None:
            db_user.last_name = user.last_name
        if user.email is not None:
            db_user.email = user.email
        if user.phonenumber is not None:
            db_user.phonenumber = user.phonenumber
        if user.password is not None:
            db_user.password = user.password
        if user.is_verified is not None:
            db_user.is_verified = user.is_verified
        if user.status is not None:
            db_user.status = user.status
        if user.connexion_type is not None:
            db_user.connexion_type = user.connexion_type
        if user.role is not None:
            db_user.role = user.role
        
        db.commit()
        db.refresh(db_user)
        
        return StandardResponse(
            statusCode=200,
            message="Utilisateur mise à jour avec succès",
            data={"user": db_user.to_dict()}
        )
    except Exception as e:
        db.rollback()
        return StandardResponse(
            statusCode=400,
            message=f"Erreur lors de la mise à jour de l'utilisateur: {str(e)}",
            data=None
        )

@router.delete("/{user_id}", response_model=StandardResponse)
def delete_user(user_id: str, db: Session = Depends(get_db)):
    """Supprime un utilisateur"""
    try:
        user = db.query(UserEntity).filter(UserEntity.id == user_id).first()
        if user is None:
            return StandardResponse(
                statusCode=404,
                message="Utilisateur non trouvé",
                data=None
            )
        
        user_dict = user.to_dict()
        
        db.delete(user)
        db.commit()
        
        return StandardResponse(
            statusCode=200,
            message="Utilisateur supprimé avec succès",
            data={"user": user_dict}
        )
    except Exception as e:
        db.rollback()
        return StandardResponse(
            statusCode=400,
            message=f"Erreur lors de la suppression de l'utilisateur: {str(e)}",
            data=None
        )


@router.post("/login", response_model=StandardResponse)
def login(user: UserLogin, db: Session = Depends(get_db)):
    """Loger un utilisateur"""
    try:
        decrypted_email = decrypt(user.email)
        decrypted_password = decrypt(user.password)

        # decrypted_email = user.email
        # decrypted_password = user.password
        # Initialize Firebase Admin SDK
        initialize_firebase()
        # Try to sign in with email and password
        try:
            # # First get the user record by email
            # user_record = auth.get_user_by_email(decrypted_email)
            # print(user_record)
            
            # # Verify the password using Firebase's built-in authentication
            # if not verify_firebase_password(decrypted_email, decrypted_password):
            #     return StandardResponse(
            #         statusCode=400,
            #         message="Invalid password",
            #         data={
            #             "From": "LOCAL Firebase"
            #         }
            #     )

            # Get user's hashed password from our database
            db_user = db.query(UserEntity).filter(UserEntity.email == decrypted_email).first()
            if not db_user:
                return StandardResponse(
                    statusCode=400,
                    message="User not found in database",
                    data={
                        "From": "LOCAL Database"
                    }
                )

            # Verify the password matches in our database
            if not verify_password(decrypted_password, db_user.to_dict().get("password")):
                return StandardResponse(
                    statusCode=400,
                    message="Invalid password",
                    data={
                        "From": "LOCAL Database"
                    }
                )
            logger.info(db_user.to_dict().get("is_verified"))
            #print(db_user)
            # Check if user is verified
            # if db_user.to_dict().get("is_verified") == "NO":
            #     return StandardResponse(
            #         statusCode=200,
            #         message="User is not verified",
            #         data={"email": db_user.to_dict().get("email"), "phonenumber": db_user.to_dict().get("phonenumber")}
            #     )
            if db_user.to_dict().get("status") == "INACTIVE":
                return StandardResponse(
                    statusCode=200,
                    message="User is inactive",
                    data={"email": db_user.to_dict().get("email"), "phonenumber": db_user.to_dict().get("phonenumber")}
                )
            # Check if user is deleted
            if db_user.to_dict().get("is_deleted") == "1":
                return StandardResponse(
                    statusCode=200,
                    message="User is deleted",
                    data=None
                )

            # Try to sign in with Firebase's built-in authentication
            try:
                
                # Get user data from Firestore
                try:
                    # Adapt Firestore data to our format
                    adapted_data = {
                        'id': db_user.to_dict().get("id"),
                        'email': db_user.to_dict().get("email"),
                        'phonenumber': db_user.to_dict().get("phonenumber"),
                        'firstName': db_user.to_dict().get("first_name"),
                        'lastName': db_user.to_dict().get("last_name"),
                        'countryId': db_user.to_dict().get("country_id"),
                        'role': db_user.to_dict().get("role"),
                        'isverified': db_user.to_dict().get("is_verified"),
                        'expires_in': int(datetime.timestamp(datetime.now() + timedelta(days=2)))
                    }

                    # Create custom token for the user
                    # Extract the user ID for the first parameter and use the rest as claims
                    custom_token = generate_token(adapted_data)

                    return StandardResponse(
                        statusCode=200,
                        message="successful login",
                        data={
                            "token": custom_token,
                        }
                    )
                except Exception as e:
                    return StandardResponse(
                        statusCode=400,
                        message=f"Error getting user data from Firestore: {str(e)}",
                        data=None
                    )
            except Exception as e:
                return StandardResponse(
                    statusCode=400,
                    message=f"Unexpected error: {str(e)}",
                    data=None
                )
        except Exception as e:
            return StandardResponse(
                statusCode=400,
                message=f"Unexpected error: {str(e)}",
                data=None
            )
    except Exception as e:
        return StandardResponse(
            statusCode=400,
            message=f"An error occurred during login. {str(e)}",
            data=None
        )





# Configuration email (à adapter selon votre fournisseur)
conf = ConnectionConfig(
    MAIL_USERNAME=os.getenv("MAIL_USERNAME", "your-email@gmail.com"),
    MAIL_PASSWORD=os.getenv("MAIL_PASSWORD", "your-app-password"),
    MAIL_FROM=os.getenv("MAIL_FROM", "your-email@gmail.com"),
    MAIL_PORT=int(os.getenv("MAIL_PORT", "587")),
    MAIL_SERVER=os.getenv("MAIL_SERVER", "smtp.gmail.com"),
    MAIL_STARTTLS=True,
    MAIL_SSL_TLS=False,
    USE_CREDENTIALS=True,
    VALIDATE_CERTS=True
)

# Template HTML pour l'email de vérification
EMAIL_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Code de Vérification / Verification Code</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }}
        .container {{
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }}
        .header {{
            text-align: center;
            background-color: #007bff;
            color: white;
            padding: 20px;
            border-radius: 10px 10px 0 0;
            margin: -20px -20px 20px -20px;
        }}
        .verification-code {{
            background-color: #f8f9fa;
            border: 2px dashed #007bff;
            padding: 20px;
            text-align: center;
            margin: 20px 0;
            border-radius: 5px;
        }}
        .code {{
            font-size: 32px;
            font-weight: bold;
            color: #007bff;
            letter-spacing: 5px;
            font-family: 'Courier New', monospace;
        }}
        .footer {{
            text-align: center;
            color: #666;
            font-size: 12px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }}
        .warning {{
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Code de Vérification / Verification Code</h1>
        </div>
        
        <p>Bonjour/Hello,</p>
        
        <p>Vous avez demandé un code de vérification pour votre compte. Voici votre code :/You have requested a verification code for your account. Here is your code:</p>
        
        <div class="verification-code">
            <div class="code">{verification_code}</div>
            <p>Ce code expire dans 10 minutes</p>
            <p>This code expires in 10 minutes</p>
        </div>
        
        <div class="warning">
            <strong>⚠️ Important :</strong>
            <ul>
                <li>Ce code est personnel et confidentiel</li>
                <li>Ne le partagez avec personne</li>
                <li>Il expire dans 10 minutes</li>
            </ul>
            <strong>⚠️ Important:</strong>
            <ul>
                <li>This code is personal and confidential</li>
                <li>Do not share it with anyone</li>
                <li>It expires in 10 minutes</li>
            </ul>
        </div>
        
        <p>Si vous n'avez pas demandé ce code, ignorez simplement cet email.</p>
        <p>If you did not request this code, just ignore this email.</p>
        
        <p>Cordialement,<br>L'équipe de sécurité</p>
        <p>Best regards,<br>The security team</p>
        
        <div class="footer">
            <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
            <p>This email was sent automatically, please do not reply.</p>
            <p>© 2025 Easy Life Pay. Tous droits réservés. / All rights reserved.</p>
        </div>
    </div>
</body>
</html>
"""

EMAIL_DELETION_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Suppression de compte / Account deletion</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }}
        .container {{
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }}
        .header {{
            text-align: center;
            background-color: #007bff;
            color: white;
            padding: 20px;
            border-radius: 10px 10px 0 0;
            margin: -20px -20px 20px -20px;
        }}
        .verification-code {{
            background-color: #f8f9fa;
            border: 2px dashed #007bff;
            padding: 20px;
            text-align: center;
            margin: 20px 0;
            border-radius: 5px;
        }}
        .code {{
            font-size: 32px;
            font-weight: bold;
            color: #007bff;
            letter-spacing: 5px;
            font-family: 'Courier New', monospace;
        }}
        .footer {{
            text-align: center;
            color: #666;
            font-size: 12px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }}
        .warning {{
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Suppression de compte / Account deletion</h1>
        </div>
        
        <p>Bonjour/Hello,</p>
        
        <p>Vous avez demandé la suppression de votre compte. Pour confirmer cette action, veuillez cliquer sur le lien suivant : <a href="{url}">Confirmer la suppression du compte</a></p>
        
        <div class="warning">
            <strong>⚠️ Important :</strong>
            <ul>
                <li>La suppression de votre compte entrainera la perte de vos données et vous ne pourrez plus vous connecter</li>
                <li>La suppression de votre compte est définitive et ne peut pas être annulée</li>
            </ul>
            <strong>⚠️ Important:</strong>
            <ul>
                <li>Deleting your account will result in the loss of your data and you will no longer be able to log in</li>
                <li>Deleting your account is final and cannot be undone</li>
            </ul>
        </div>
        
        <p>Cordialement,<br>L'équipe de sécurité</p>
        <p>Best regards,<br>The security team</p>
        
        <div class="footer">
            <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
            <p>This email was sent automatically, please do not reply.</p>
            <p>© 2025 IZI Life Pay. Tous droits réservés. / All rights reserved.</p>
        </div>
    </div>
</body>
</html>
"""


def generate_verification_code(length: int = 6) -> str:
    """Génère un code de vérification aléatoire"""
    return ''.join(random.choices(string.digits, k=length))

async def send_verification_email(email: str, verification_code: str):
    """Envoie l'email de vérification"""
    try:
        # Créer le message HTML
        html_content = EMAIL_TEMPLATE.format(verification_code=verification_code)
        
        message = MessageSchema(
            subject="🔐 Votre code de vérification (IZI Life Pay)",
            recipients=[email],
            body=html_content,
            subtype=MessageType.html
        )
        
        fm = FastMail(conf)
        await fm.send_message(message)
        print(f"Email de vérification envoyé à {email}")
        
    except Exception as e:
        print(f"Erreur lors de l'envoi de l'email: {e}")
        raise e

async def send_deletion_email(email: str, url: str):
    """Envoie l'email de vérification"""
    try:
        # Créer le message HTML
        html_content = EMAIL_DELETION_TEMPLATE.format(url=url)
        
        message = MessageSchema(
            subject="🔐 Suppression de compte (IZI Life Pay)",
            recipients=[email],
            body=html_content,
            subtype=MessageType.html
        )
        
        fm = FastMail(conf)
        await fm.send_message(message)
        print(f"Email de vérification envoyé à {email}")
        
    except Exception as e:
        print(f"Erreur lors de l'envoi de l'email: {e}")
        raise e

async def send_verification_email_for_delete_account(email: str, verification_code: str):
    try:
        # Créer le message HTML
        html_content = EMAIL_DELETION_TEMPLATE.format(verification_code=verification_code)
        
        message = MessageSchema(
            subject="🔐 Votre code de vérification (IZI Life Pay)",
            recipients=[email],
            body=html_content,
            subtype=MessageType.html
        )
        
        fm = FastMail(conf)
        await fm.send_message(message)
        print(f"Email de vérification envoyé à {email}")
        
    except Exception as e:
        print(f"Erreur lors de l'envoi de l'email: {e}")
        raise e


async def create_and_send_verification_code(email: str, background_tasks: BackgroundTasks, db: Session):
    """Fonction interne pour créer et envoyer un code de vérification"""
    try:
        # Générer le code de vérification
        verification_code = generate_verification_code()
        
        # Supprimer l'ancien code s'il existe
        existing_code = db.query(VerificationCodeEntity).filter(VerificationCodeEntity.email == email).first()
        if existing_code:
            db.delete(existing_code)
            db.commit()
            logger.info(f"Ancien code de vérification supprimé pour: {email}")
        
        # Sauvegarder le nouveau code avec expiration dans 10 minutes
        from datetime import datetime, timedelta
        expires_at = datetime.now() + timedelta(minutes=10)
        verification_code_entity = VerificationCodeEntity(
            code=verification_code, 
            email=email,
            expires_at=expires_at
        )
        db.add(verification_code_entity)
        db.commit()
        logger.info(f"Nouveau code de vérification sauvegardé pour: {email}")
        
        # Envoyer l'email en arrière-plan
        background_tasks.add_task(send_verification_email, email, verification_code)
        
        return verification_code
        
    except Exception as e:
        logger.error(f"Erreur lors de la création du code de vérification: {e}")
        raise e

# Stockage temporaire des codes (en production, utilisez Redis ou votre DB)
verification_codes = {}

@router.post("/send-verification-code", response_model=StandardResponse)
async def send_verification_code(
    check_email: CheckEmail, 
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Send verification code to user email"""
    logger.info(f"check in VerificationCodeEntity email: {check_email.email}")
    decrypted_email = decrypt(check_email.email)
    
    try:
        user = db.query(UserEntity).filter(UserEntity.email == decrypted_email).first()
    
    
        if user is None:
            return StandardResponse(
                statusCode=404,
                message="user not found",
                data=None
            )
    
        # Générer le code de vérification
        verification_code = generate_verification_code()
        
        # Envoyer l'email en arrière-plan
        background_tasks.add_task(send_verification_email, decrypted_email, verification_code)

        #check in VerificationCodeEntity email
        logger.info(f"check in VerificationCodeEntity email: {decrypted_email}")
        verification_code_entity = db.query(VerificationCodeEntity).filter(VerificationCodeEntity.email == decrypted_email).first()

        if verification_code_entity is not None:
            db.delete(verification_code_entity)
            db.commit()
            logger.info(f"VerificationCodeEntity email: {decrypted_email} deleted")

        # Sauvegarder le nouveau code avec expiration dans 10 minutes
        from datetime import datetime, timedelta
        expires_at = datetime.now() + timedelta(minutes=10)
        verification_code_entity = VerificationCodeEntity(
            code=verification_code, 
            email=decrypted_email,
            expires_at=expires_at
        )
        db.add(verification_code_entity)
        db.commit()
        
        return StandardResponse(
            statusCode=200,
            message="Success verification code",
            data={
                "email": decrypted_email,
                "message": "Vérifiez votre boîte email pour le code de vérification"
            }
        )
    except Exception as e:
        return StandardResponse(
            statusCode=500,
            message="Internal server error",
            data=None
        )

@router.post("/verify-code", response_model=StandardResponse)
def verify_code(sended_data: CheckEmailAndCode, db: Session = Depends(get_db)):
    """Vérifier le code de vérification"""
    decrypted_email = decrypt(sended_data.email)
    decrypted_code = decrypt(sended_data.code)
    
    # Vérifier si le code existe
    verification_code_entity = db.query(VerificationCodeEntity).filter(VerificationCodeEntity.email == decrypted_email, VerificationCodeEntity.code == decrypted_code).first()
    if verification_code_entity is None:
        return StandardResponse(
            statusCode=404,
            message="Code de vérification non trouvé",
            data=None
        )
    
    stored_code = verification_code_entity
    
    # Vérifier si le code a expiré
    if stored_code.expires_at < datetime.now():
        db.delete(verification_code_entity)
        db.commit()
        return StandardResponse(
            statusCode=400,
            message="Code de vérification expiré",
            data=None
        )
    
    # Vérifier si le code correspond
    if stored_code.code != decrypted_code:
        return StandardResponse(
            statusCode=400,
            message="Code de vérification invalide",
            data=None
        )
    
    # Code valide, supprimer de la mémoire
    db.delete(verification_code_entity)
    db.commit()

    #update user status
    user = db.query(UserEntity).filter(UserEntity.email == decrypted_email).first()
    user.isverified = True
    user.status = 'ACTIVE'
    db.add(user)
    db.commit()
    
    return StandardResponse(
        statusCode=200,
        message="Success verification code",
        data={
            "verified": True,
            "email":decrypted_email
        }

    )


#change Password
@router.post("/change-password",response_model=StandardResponse)
async def change_password(myuser: UserChangePassword, db: Session = Depends(get_db)):
    try:
        decrypted_email = decrypt(myuser.email)
        decrypted_password = decrypt(myuser.password)
        decrypted_confirm_password = decrypt(myuser.confirm_password)
        user = db.query(UserEntity).filter(UserEntity.email == decrypted_email).first()
        if user is None:
            return StandardResponse(
                statusCode=404,
                message="user not found",
                data=None
            )
        if decrypted_password != decrypted_confirm_password:
            return StandardResponse(
                statusCode=400,
                message="Password do not match",
                data=None
            )
        if len(decrypted_password) < 8:
            return StandardResponse(
                statusCode=400,
                message="Password must be at least 8 characters long",
                data=None
            )
        
        if len(decrypted_password) > 20:
            return StandardResponse(
                statusCode=400,
                message="Password must be at most 20 characters long",
                data=None
            )
        
        if not re.match("^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,20}$", decrypted_password):
            return StandardResponse(
                statusCode=400,
                message="Password must contain at least one lowercase letter, one uppercase letter, one digit, and one special character",
                data=None
            )
        
        #change to firebase
        initialize_firebase()
        try:
            # Récupérer l'utilisateur Firebase par email
            firebase_user = auth.get_user_by_email(decrypted_email)
            
            # Mettre à jour le mot de passe
            auth.update_user(
                firebase_user.uid,
                password=decrypted_password
            )
            
            print(f"Mot de passe Firebase mis à jour pour l'utilisateur: {decrypted_email}")
        except auth.UserNotFoundError:
            print(f"Utilisateur Firebase non trouvé: {decrypted_email}")


        user.password = get_password_hash(decrypted_password)
        db.commit()
        db.refresh(user)

        return StandardResponse(
            statusCode=200,
            message="Password changed successfully",
            data=None
        )
    except Exception as e:
        return StandardResponse(
            statusCode=500,
            message="Internal server error",
            data=None
        )
    
#user want to delete Account
@router.post("/submit-to-delete-account")
def submit_to_delete_account(email: str,background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    try:
        #check email
        decrypted_email = decrypt(email)
        # decrypted_email = email
        user = db.query(UserEntity).filter(UserEntity.email == decrypted_email).first()
        if user is None:
            return JSONResponse(
                status_code=404,
                content = {
                    "message": "user not found",
                }
            )
        # Envoyer l'email en arrière-plan
        background_tasks.add_task(send_deletion_email, user.email, "http://localhost:8000/delete-account")
        return JSONResponse(
            status_code=200,
            content = {
                "message": "success submit to delete account",
            }
        )
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content = {
                "message": f"error {str(e)}",
            }
        )

#check email for send verification code to delete account
@router.post("/check-email-for-delete-account")
def check_email_for_delete_account(email: str, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """Check if a user exists by email"""
    
    try:
        decrypted_email = decrypt(email)
        user = db.query(UserEntity).filter(UserEntity.email == decrypted_email).first()
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content = {
                "message": "Internal server error",
                "error": str(e)
            }
        )
    if user is None:
        return JSONResponse(
            status_code=404,
            content = {
                "message": "user not found",
            }
        )
    #send verification code
    verification_code = generate_verification_code()

    #send verification code to user email
    background_tasks.add_task(send_verification_email_for_delete_account, user.email, verification_code)
    try:
        #check in VerificationCodeEntity email
        logger.info(f"check in VerificationCodeEntity email: {decrypted_email}")
        verification_code_entity = db.query(VerificationCodeEntity).filter(VerificationCodeEntity.email == decrypted_email).first()

        if verification_code_entity is not None:
            db.delete(verification_code_entity)
        db.commit()
        logger.info(f"VerificationCodeEntity email: {decrypted_email} deleted")

        # Sauvegarder le nouveau code avec expiration dans 10 minutes
        from datetime import datetime, timedelta
        expires_at = datetime.now() + timedelta(minutes=10)
        verification_code_entity = VerificationCodeEntity(
            code=verification_code, 
            email=decrypted_email,
            expires_at=expires_at
        )
        db.add(verification_code_entity)
        db.commit()

        return JSONResponse(
        status_code=200,
        content = {
            "message": "success check email for delete account",
            "user": user.to_dict()
        }
    )
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content = {
                "message": "Internal server error",
                "error": str(e)
            }
        )    
    
