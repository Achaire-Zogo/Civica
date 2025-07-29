#!/usr/bin/env python3
import os
from typing import Optional
from datetime import datetime, timedelta
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, UniqueConstraint, func, text
from pydantic import BaseModel
from database import Base

class VerificationCodeEntity(Base):
    __tablename__ = "verification_codes"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(String(10), unique=True, index=True, nullable=False)
    email = Column(String(100), nullable=False)
    created_at = Column(DateTime, default=func.now(), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    
    def to_dict(self):
        """Convertit l'entité en dictionnaire"""
        return {
            'id': self.id,
            'code': self.code,
            'email': self.email,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'expires_at': self.expires_at.isoformat() if self.expires_at else None
        }
    
    def __repr__(self):
        return f"<VerificationCode(id={self.id}, code='{self.code}', email='{self.email}')>"

# Modèles Pydantic pour la validation des données
class VerificationCodeBase(BaseModel):
    id: Optional[int] = None
    code: Optional[str] = None
    email: Optional[str] = None
    created_at: Optional[str] = None
    expires_at: Optional[str] = None

# Modèle pour la création
class VerificationCodeCreate(BaseModel):
    code: str
    email: str

# Modèle pour la mise à jour
class VerificationCodeUpdate(BaseModel):
    code: Optional[str] = None
    email: Optional[str] = None

# Modèle pour la réponse
class VerificationCodeResponse(VerificationCodeBase):
    id: int
    
    class Config:
        from_attributes = True  # Remplace orm_mode=True dans Pydantic v2
