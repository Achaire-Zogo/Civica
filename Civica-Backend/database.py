#!/usr/bin/env python3
import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import logging
import pymysql

# Charger les variables d'environnement
load_dotenv()

# Configurer le logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Configuration de la base de données
DATABASE_URL = f"mysql+pymysql://{os.getenv('MYSQL_USER')}:{os.getenv('MYSQL_PASSWORD')}@{os.getenv('MYSQL_HOST')}:{os.getenv('MYSQL_PORT')}/{os.getenv('MYSQL_DB', 'civica_db')}"

# Créer le moteur SQLAlchemy
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Fonction pour créer les tables dans la base de données
def create_tables():
    Base.metadata.create_all(bind=engine)
    print("Tables créées avec succès")

# Fonction pour obtenir une session de base de données
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Fonction pour initialiser la base de données
def init_database():
    try:
        logger.info("Initialisation de la base de données...")
        # Récupérer les informations de connexion depuis les variables d'environnement
        mysql_host = os.getenv('MYSQL_HOST')
        mysql_port = int(os.getenv('MYSQL_PORT'))
        mysql_user = os.getenv('MYSQL_USER')
        mysql_password = os.getenv('MYSQL_PASSWORD')
        mysql_database = os.getenv('MYSQL_DB', 'civica_db')
        
        logger.info(f"Connexion à MySQL: {mysql_host}:{mysql_port} avec l'utilisateur {mysql_user}")
        
        # Créer la base de données si elle n'existe pas
        conn = pymysql.connect(
            host=mysql_host,
            port=mysql_port,
            user=mysql_user,
            password=mysql_password
        )
        
        cursor = conn.cursor()
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {mysql_database}")
        conn.commit()
        
        logger.info(f"Base de données '{mysql_database}' créée ou déjà existante.")
        
        cursor.close()
        conn.close()
        
        return True
        
    except Exception as e:
        logger.error(f"Erreur lors de l'initialisation de la base de données: {e}")
        return False


# Fonction pour ajouter des données de test
def seed_database():
    try:
        logger.info("Ajout des données de test...")
    except Exception as e:
        logger.error(f"Erreur lors de l'ajout des données de test: {e}")
        return False
