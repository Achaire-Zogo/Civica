#!/usr/bin/env python3
"""
Gestionnaire principal des seeders
"""
import logging
from sqlalchemy.orm import Session
from .constitution_seeder import seed_constitution_data

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def run_all_seeders(db: Session):
    """Exécute tous les seeders disponibles"""
    try:
        logger.info("=== DÉBUT DU SEEDING ===")
        
        # Exécuter le seeder de la Constitution
        seed_constitution_data(db)
        
        logger.info("=== SEEDING TERMINÉ AVEC SUCCÈS ===")
        
    except Exception as e:
        logger.error(f"Erreur lors du seeding: {str(e)}")
        raise
