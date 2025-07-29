#!/usr/bin/env python3
from typing import List, Optional
from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from database import Base

# SQLAlchemy Models (Database Tables)
class ThemeEntity(Base):
    __tablename__ = "themes"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    icon = Column(String(100), nullable=True)
    color = Column(String(7), nullable=True)  # Hex color code
    is_active = Column(Boolean, default=True)
    order_index = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    levels = relationship("LevelEntity", back_populates="theme", cascade="all, delete-orphan")
    
    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "icon": self.icon,
            "color": self.color,
            "is_active": self.is_active,
            "order_index": self.order_index,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "levels_count": len(self.levels) if self.levels else 0
        }
# Pydantic Models (API Request/Response)
class ThemeBase(BaseModel):
    title: str
    description: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[str] = None
    is_active: bool = True
    order_index: int = 0

class ThemeCreate(ThemeBase):
    pass

class ThemeUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[str] = None
    is_active: Optional[bool] = None
    order_index: Optional[int] = None

class ThemeResponse(ThemeBase):
    id: str
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
    levels_count: int = 0
    
    class Config:
        from_attributes = True

class ThemeForQuiz(BaseModel):
    id: str
    title: str
    description: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[str] = None
    levels: List[dict] = []  # Use dict to avoid circular imports
    
    class Config:
        from_attributes = True