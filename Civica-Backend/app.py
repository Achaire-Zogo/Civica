#!/usr/bin/env python3
import os
import sys
import pymysql
import logging
import uuid
import shutil
from typing import List, Optional
from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from dotenv import load_dotenv
from models import *  # Importe tous les modèles
from database import SessionLocal, Base, engine, create_tables, init_database, seed_database
from routes.user_route import router as user_router
from routes.kyc_route import router as kyc_router
from routes.theme_route import router as theme_router
from routes.level_route import router as level_router
from routes.question_route import router as question_router
# Configurer le logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Charger les variables d'environnement avant d'importer les autres modules
load_dotenv()

# Initialiser l'application FastAPI
app = FastAPI(
    title="Civica API",
    description="API pour la Quiz sur l'apprentissage de code electoral",
    version="1.0.0",
    docs_url="/swagger"
)

# Ajouter le middleware CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Endpoint de santé pour Eureka
@app.get('/api/health', tags=['Système'])
def health_check():
    """Endpoint de vérification de santé pour Eureka"""
    return {"status": "UP"}

@app.on_event("startup")
async def startup_event():
    # Initialiser la base de données
    logger.info("Initialisation de la base de données...")
    if init_database():
        #creation de la base de donnee
        create_tables()
        seed_database()
    else:
        logger.error("Impossible de démarrer l'application en raison d'erreurs d'initialisation.")
        sys.exit(1)

# Inclure les routers
app.include_router(user_router)
app.include_router(kyc_router)
app.include_router(theme_router)
app.include_router(level_router)
app.include_router(question_router)

# Point d'entrée principal
if __name__ == '__main__':
    # Récupérer le port de l'application depuis les variables d'environnement
    app_port = int(os.getenv('SERVER_PORT', 5002))
    logger.info(f"Port de l'application configuré: {app_port}")
    
    # Initialiser la base de données
    if init_database():
        #creation de la base de donnee
        create_tables()
        # Ajouter des données de test (Canada et Cameroun)
        seed_database()
        # Démarrer l'application FastAPI avec uvicorn
        import uvicorn
        logger.info(f"Démarrage de l'application FastAPI sur le port {app_port}...")
        uvicorn.run("app:app", host="0.0.0.0", port=app_port, reload=True)
    else:
        logger.error("Impossible de démarrer l'application en raison d'erreurs d'initialisation.")
        sys.exit(1)
