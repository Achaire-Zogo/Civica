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

@router.get("/")
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
        message = f"users founds with email '{email}'"
    else:
        message = "users founds"
    
    return JSONResponse(
        status_code=200,
        content={
            "message": message,
            "data": {"users": user_list}
        }
    )

@router.get("/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_db)):
    """Obtient un utilisateur par son ID"""

    try:
        user = db.query(UserEntity).filter(UserEntity.id == user_id).first()
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "message": "Internal server error",
                "data": None
            }
        )
    if user is None:
        return JSONResponse(
            status_code=404,
            content={
            "message":"user not found",
            "data":None
            }
            
        )
    return JSONResponse(
        status_code=200,
        content={
            "message":"success retrieve user",
            "data":{"user": user.to_dict()}
        }
    )

#check user by email
@router.get("/check-email/{email}")
def check_user_by_email(email: str, db: Session = Depends(get_db)):
    """Check if a user exists by email"""
    
    try:
        user = db.query(UserEntity).filter(UserEntity.email == email).first()
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "message":"Internal server error",
                "data":None
            }
            
        )
    if user is None:
        return JSONResponse(
            status_code=404,
            content={
            "message":"user not found",
            "data":None
            }
            
        )
    return JSONResponse(
        status_code=200,
        content={
            "message":"success retrieve user",
            "data":{"user": user.to_dict()}
        }
    )



@router.post("/register")
async def register(user: UserRegister, db: Session = Depends(get_db)):
    """Register a new user with improved error handling and logic"""
    
    
    try:
        # 1. Decrypt user data
        user_email = user.email
        user_password = user.password
        user_pseudo = user.spseudo
        
        # Check local database
        try:
            existing_user_email = db.query(UserEntity).filter(UserEntity.email == user_email).first()
            if existing_user_email:
                logger.info(f"User with this email already exists local database: {user_email}")
                return JSONResponse(
                    status_code=409,  # ✅ Correct status code
                    content={
                        "message": "User with this email already exists",
                        "error": "Email already in use local database"
                    }
                )
            
            existing_user_pseudo = db.query(UserEntity).filter(UserEntity.spseudo == user_pseudo).first()
            if existing_user_pseudo:
                logger.info(f"User with this pseudo already exists local database: {user_pseudo}")
                return JSONResponse(
                    status_code=409,  # ✅ Correct status code
                    content={
                        "message": "User with this pseudo already exists",
                        "error": "pseudo already in use local database"
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
        # Create local database user
        hashed_password = get_password_hash(user_password)
        # Check if user already exists in local database
        new_user = UserEntity(
        id=uuid.uuid4(),
            email=user_email,
            password=hashed_password,
            is_verified='YES',
            status='ACTIVE',
            connexion_type='EMAIL',
            role='USER',
            spseudo=user_pseudo
        )
        
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        logger.info("Local database user created")
        # Prepare response
        user_dict = new_user.to_dict()
        if 'password' in user_dict:
            del user_dict['password']
        
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



@router.put("/{user_id}")
def update_user(user_id: str, user: UserUpdate, db: Session = Depends(get_db)):
    """Met à jour un utilisateur existant"""
    try:
        db_user = db.query(UserEntity).filter(UserEntity.id == user_id).first()
        if db_user is None:
            return JSONResponse(
                status_code=404,
                content={
                    "message":"user not found",
                    "data":None
                }
            )
        
        # Mettre à jour les champs
        if user.spseudo is not None:
            db_user.spseudo = user.spseudo
        if user.email is not None:
            db_user.email = user.email
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
        
        return JSONResponse(
            status_ode=200,
            content={
                "message":"user updated successfully",
                "data": db_user.to_dict
            }
        )
    except Exception as e:
        db.rollback()
        return JSONResponse(
            status_ode=400,
            message=f"Erreur lors de la mise à jour de l'utilisateur: {str(e)}",
            data=None
        )

@router.delete("/{user_id}")
def delete_user(user_id: str, db: Session = Depends(get_db)):
    """Supprime un utilisateur"""
    try:
        user = db.query(UserEntity).filter(UserEntity.id == user_id).first()
        if user is None:
            return JSONResponse(
                status_code=404,
                content={
                    "message": "user not found",
                    "data":""
                }
            )
        
        user_dict = user.to_dict()
        
        db.delete(user)
        db.commit()
        
        return JSONResponse(
            status_code=200,
            content={
                "message":"user deleted",
                "data": user_dict
            }
        )
    except Exception as e:
        db.rollback()
        return JSONResponse(
            status_code=400,
            content={
                "message":"error occured",
                "data":""
            }
        )


@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    """Loger un utilisateur"""
    try:
        user_email = user.email
        user_password = user.password
        try:
            db_user = db.query(UserEntity).filter(UserEntity.email == user_email).first()
            if not db_user:
                return JSONResponse(
                    status_code=400,
                    content={
                        "message":"user not found",
                        "data":""
                    }
                )
            if not verify_password(user_password, db_user.to_dict().get("password")):
                return JSONResponse(
                    status_code=400,
                    content={
                        "message":"invalid password",
                        "data": ""
                    }
                )
            if db_user.to_dict().get("status") == "INACTIVE":
                return StandardResponse(
                    status_code=400,
                    content={
                        "message":"user is inactive",
                        "data": db_user.to_dict().get("email")
                    }
                )
            if db_user.to_dict().get("is_deleted") == "1":
                return JSONResponse(
                    status_code=400,
                    content={
                        "message":"user is deleted",
                        "data":""
                    }
                )
            try:
                try:
                    adapted_data = {
                        'id': db_user.to_dict().get("id"),
                        'email': db_user.to_dict().get("email"),
                        'pseudo': db_user.to_dict().get("pseudo"),
                        'role': db_user.to_dict().get("role"),
                        'isverified': db_user.to_dict().get("is_verified"),
                        'expires_in': int(datetime.timestamp(datetime.now() + timedelta(days=2)))
                    }
                    custom_token = generate_token(adapted_data)

                    return JSONResponse(
                        status_code=200,
                        content={
                            "message":"successful login",
                            "data":{
                                "token": custom_token,
                            }
                        }
                    )
                except Exception as e:
                    return JSONResponse(
                        status_code=400,
                        content={
                            "message":"error getting user",
                            "data":""
                        }
                    )
            except Exception as e:
                return JSONResponse(
                    status_code=400,
                    content={
                        "message":f"Unexpected error: {str(e)}",
                        "data":""
                    }
                )
        except Exception as e:
            return JSONResponse(
                status_code=400,
                content={
                    "message":f"Unexpected error: {str(e)}",
                    "data":""
                }
            )
    except Exception as e:
        return JSONResponse(
            status_code=400,
            content={
                "message":"error occured ",
                "data":f"##### {str(e)}"
            }
        )



#change Password
@router.post("/change-password")
async def change_password(myuser: UserChangePassword, db: Session = Depends(get_db)):
    try:
        user_email = myuser.email
        user_password = myuser.password
        user_confirm_password = myuser.confirm_password
        user = db.query(UserEntity).filter(UserEntity.email == user_email).first()
        if user is None:
            return JSONResponse(
                status_code=404,
                content={
                    "message":"user not found",
                    "data":""
                }
            )
        if user_password != user_confirm_password:
            return JSONResponse(
                status_code=400,
                content={
                    "message":"password not match",
                    "data":""
                }
            )
        if len(user_password) < 8:
            return JSONResponse(
                status_code=400,
                content={
                    "message":"password must be at least 8 characters long",
                    "data":""
                }
            )
        
        if len(user_password) > 20:
            return JSONResponse(
                status_code=400,
                content={
                    "message":"password must be at most 20 characters long",
                    "data":""
                }
            )
        
        if not re.match("^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,20}$", user_password):
            return JSONResponse(
                status_code=400,
                content={
                    "message":"password must contain at least one lowercase letter, one uppercase letter, one digit, and one special character",
                    "data":""
                }
            )


        user.password = get_password_hash(user_password)
        db.commit()
        db.refresh(user)

        return JSONResponse(
            status_code=200,
            content={
                "message":"password changed successfully",
                "data":""
            }
        )
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "message":"Internal server error",
                "data":""
            }
        )
    
