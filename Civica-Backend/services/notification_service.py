import firebase_admin
from firebase_admin import messaging
from firebase_admin.credentials import Certificate
import os
import logging
from typing import Optional

logger = logging.getLogger(__name__)

class NotificationService:
    def __init__(self):
        # Initialiser Firebase Admin SDK seulement si ce n'est pas déjà fait
        if not firebase_admin._apps:
            try:
                # Chemin vers le fichier de configuration Firebase
                cred_path = os.getenv('FIREBASE_CREDENTIALS_PATH', 'serviceAccountKey.json')
                cred = Certificate(cred_path)
                firebase_admin.initialize_app(cred)
                logger.info("Firebase Admin SDK initialisé avec succès")
            except Exception as e:
                logger.error(f"Erreur lors de l'initialisation de Firebase: {e}")
                raise

    async def send_chat_notification(
        self, 
        token: str, 
        title: str, 
        body: str, 
        data: Optional[dict] = None
    ) -> Optional[str]:
        """
        Envoie une notification push via FCM
        
        Args:
            token: Le token FCM du destinataire
            title: Le titre de la notification
            body: Le corps du message
            data: Données supplémentaires à envoyer avec la notification
            
        Returns:
            str: L'ID du message envoyé ou None en cas d'échec
        """
        if not token:
            logger.warning("Aucun token FCM fourni, notification non envoyée")
            return None
            
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                token=token,
                data=data or {}
            )
            
            response = messaging.send(message)
            logger.info(f"Notification envoyée avec succès: {response}")
            return response
            
        except Exception as e:
            logger.error(f"Erreur lors de l'envoi de la notification: {e}")
            return None
