#!/usr/bin/env python3
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Dict

from database import get_db
from models.model_user import UserEntity
from models.utils_model import FCMToken
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from dependencies import StandardResponse, handle_exception
from security.crypt import decrypt
from security.token_utils import verify_token
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
router = APIRouter(
    prefix="/api/notifications",
    tags=["notifications"]
)

http_bearer = HTTPBearer()

@router.post("/fcm-token", response_model=StandardResponse)
async def update_fcm_token(
    token_data: FCMToken,
    db: Session = Depends(get_db),
    credentials: HTTPAuthorizationCredentials = Depends(http_bearer)
):
    """
    Met à jour le token FCM d'un utilisateur
    
    Args:
        token_data: Dictionnaire contenant le token FCM
            - fcm_token: Le token FCM à enregistrer
            - user_id: L'ID de l'utilisateur
            
    Returns:
        Un message de succès ou d'erreur
    """
    try:
        decrypt_user_id = decrypt(token_data.user_id)

        if not credentials.credentials:
            return StandardResponse(statusCode=404, message="token not found", data=None)
        #verify token
        verif_token = verify_token(credentials.credentials)
        if not verif_token:
            return StandardResponse(statusCode=401, message="Unauthorized", data=None)
        
        user_id = decrypt_user_id
        
        user = db.query(UserEntity).filter(UserEntity.id == user_id).first()
        if not user:
            return StandardResponse(statusCode=404, message="User not found", data=None)
            
        user.fcm_token = token_data.fcm_token
        db.commit()
        logger.info("FCM token updated successfully for user %s", user_id)
        return StandardResponse(statusCode=200, message="Token FCM mis à jour avec succès", data=None)
        
    except Exception as e:
        db.rollback()
        logger.error("Error updating FCM token: %s", e)
        return handle_exception(e, context="Error updating FCM token")
