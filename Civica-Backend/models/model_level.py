#!/usr/bin/env python3
from typing import List, Optional
from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from database import Base

class LevelEntity(Base):
    __tablename__ = "levels"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    theme_id = Column(String(36), ForeignKey("themes.id"), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    difficulty = Column(String(20), default="easy")  # easy, medium, hard
    order_index = Column(Integer, default=0)
    is_active = Column(Boolean, default=True)
    min_score_to_unlock = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    theme = relationship("ThemeEntity", back_populates="levels")
    questions = relationship("QuestionEntity", back_populates="level", cascade="all, delete-orphan")
    
    def to_dict(self):
        return {
            "id": self.id,
            "theme_id": self.theme_id,
            "title": self.title,
            "description": self.description,
            "difficulty": self.difficulty,
            "order_index": self.order_index,
            "is_active": self.is_active,
            "min_score_to_unlock": self.min_score_to_unlock,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "questions_count": len(self.questions) if self.questions else 0,
            "theme": self.theme.to_dict() if self.theme else None
        }



class LevelBase(BaseModel):
    theme_id: str
    title: str
    description: Optional[str] = None
    difficulty: str = "easy"
    order_index: int = 0
    is_active: bool = True
    min_score_to_unlock: int = 0

class LevelCreate(LevelBase):
    pass

class LevelUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    difficulty: Optional[str] = None
    order_index: Optional[int] = None
    is_active: Optional[bool] = None
    min_score_to_unlock: Optional[int] = None


class LevelForQuiz(BaseModel):
    id: str
    title: str
    description: Optional[str] = None
    difficulty: str
    questions: List["QuestionForQuiz"] = []
    
    class Config:
        from_attributes = True

class LevelResponse(LevelBase):
    id: str
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
    questions_count: int = 0
    
    class Config:
        from_attributes = True