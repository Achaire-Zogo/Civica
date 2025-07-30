#!/usr/bin/env python3
import os
from typing import Optional
from datetime import datetime
from enum import Enum
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, UniqueConstraint, Enum as SQLEnum, func
from pydantic import BaseModel, EmailStr, Field, ConfigDict
from database import Base


class IsVerified(Enum):
    NO = 'NO'
    YES = 'YES'

class Status(Enum):
    ACTIVE = 'ACTIVE'
    INACTIVE = 'INACTIVE'

class ConnexionType(Enum):
    EMAIL = 'EMAIL'
    PHONE = 'PHONE'
    GOOGLE = 'GOOGLE'
    FACEBOOK = 'FACEBOOK'

class Role(Enum):
    USER = 'USER'
    ADMIN = 'ADMIN'

class UserEntity(Base):
    """
    Modèle SQLAlchemy pour les utilisateurs UserEntity
    """
    __tablename__ = 'users'
    
    id = Column(String(36), primary_key=True, unique=True, index=True)
    spseudo = Column(String(50), nullable=True)
    email = Column(String(100), unique=True, nullable=False)
    password = Column(String(255), nullable=True)
    is_verified = Column(SQLEnum(IsVerified), default=IsVerified.NO)
    status = Column(SQLEnum(Status), default=Status.INACTIVE)
    connexion_type = Column(SQLEnum(ConnexionType), default=ConnexionType.EMAIL)
    role = Column(SQLEnum(Role), default=Role.USER)
    is_deleted = Column(Boolean, default=False)
    fcm_token = Column(String(255), nullable=True)
    point = Column(Integer, default=0, nullable=False)
    niveaux = Column(Integer, default=1, nullable=False)
    vies = Column(Integer, default=3, nullable=False)
    last_life_refresh = Column(DateTime, default=func.now(), nullable=False)
    created_at = Column(DateTime, default=func.now(), nullable=False)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False)
    
    def to_dict(self):
        """Convertit l'entité en dictionnaire"""
        return {
            'id': self.id,
            'spseudo': self.spseudo,
            'email': self.email,
            'password': self.password,
            'is_verified': self.is_verified.value,
            'status': self.status.value,
            'connexion_type': self.connexion_type.value,
            'role': self.role.value,
            'is_deleted': self.is_deleted,
            'fcm_token': self.fcm_token,
            'point': self.point,
            'niveaux': self.niveaux,
            'vies': self.vies,
            'last_life_refresh': self.last_life_refresh.isoformat() if self.last_life_refresh else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

# Modèles Pydantic pour la validation des données
class UserBase(BaseModel):
    id: Optional[str] = None
    spseudo: Optional[str] = None
    email: Optional[str] = None
    password: Optional[str] = None
    is_verified: Optional[IsVerified] = None
    status: Optional[Status] = None
    connexion_type: Optional[ConnexionType] = None
    role: Optional[Role] = None
    is_deleted: Optional[bool] = None
    fcm_token: Optional[str] = None
    point: Optional[int] = None
    niveaux: Optional[int] = None
    vies: Optional[int] = None
    last_life_refresh: Optional[str] = None
    created_at: str
    updated_at: str

# Modèles Pydantic pour la validation des données
class UserCreate(UserBase):
    pass

class UserUpdate(UserBase):
    spseudo: Optional[str] = None
    email: Optional[str] = None
    password: Optional[str] = None
    is_verified: Optional[IsVerified] = None
    status: Optional[Status] = None
    connexion_type: Optional[ConnexionType] = None
    role: Optional[Role] = None
    is_deleted: Optional[bool] = None
    fcm_token: Optional[str] = None
    point: Optional[int] = None
    niveaux: Optional[int] = None

class UserLogin(BaseModel):
    """Model for user login credentials"""
    email: str = "koro1@gmail.com"  # Changed from EmailStr to str to accept encrypted email
    password: str = "123456789"

    model_config = ConfigDict(from_attributes=True)

class UserRegister(BaseModel):
    """Model for user registration"""
    email: str = "koro1@gmail.com"  # Changed from EmailStr to str to accept encrypted email
    password: str = "123456789"
    spseudo: str = "zaz"
    fcm_token: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

class UserResponse(UserBase):
    id: str
    
    class Config:
        from_attributes = True  # Remplace orm_mode=True dans Pydantic v2
