#!/usr/bin/env python3
from typing import Optional
from sqlalchemy.orm import Session
from pydantic import BaseModel
import logging
import sys
import traceback

logger = logging.getLogger(__name__)

# Dépendance pour obtenir la session de base de données
def get_db():
    from app import SessionLocal
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Modèle de réponse standardisée
class StandardResponse(BaseModel):
    statusCode: int
    message: str
    data: Optional[dict] = None

def handle_exception(e: Exception, context: str = "Unhandled error") -> StandardResponse:
    exc_type, exc_obj, tb = sys.exc_info()
    line_number = tb.tb_lineno if tb else 'unknown'
    
    logger.error(f"{context}: {str(e)} | Line: {line_number}")
    logger.error("Traceback:\n" + traceback.format_exc())
    
    return StandardResponse(
        statusCode=500,
        message=f"{context}: {str(e)} | Line: {line_number}",
        data=None
    )
