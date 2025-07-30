#!/usr/bin/env python3
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from models.model_themes import (
    ThemeEntity, ThemeCreate, ThemeUpdate, ThemeResponse, ThemeForQuiz
)
from models.model_level import (
    LevelEntity, LevelCreate, LevelUpdate, LevelResponse, LevelForQuiz
)
from models.model_question import (
    QuestionEntity, QuestionCreate, QuestionUpdate, QuestionResponse, QuestionForQuiz
)
from security.token_utils import verify_token
from dependencies import get_db, StandardResponse
import logging
import uuid
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/level",
    tags=["Level"],
    responses={404: {"description": "Not found"}},
)

# LEVEL ENDPOINTS

@router.get("/")
def get_levels(db: Session = Depends(get_db)):
    """Get all levels"""
    try:
        levels = db.query(LevelEntity).filter(LevelEntity.is_active == True).order_by(LevelEntity.order_index).all()
        level_list = [level.to_dict() for level in levels]
        return JSONResponse(
            status_code=200,
            content={
                "message": "Levels retrieved successfully",
                "data": level_list
            }
        )
    except Exception as e:
        logger.error(f"Error getting levels: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={
                "message": "Internal server error",
                "error": str(e)
            }
        )

@router.get("/{theme_id}/levels")
def get_theme_levels(theme_id: str, db: Session = Depends(get_db)):
    """Get all levels for a specific theme"""
    try:
        # Check if theme exists
        theme = db.query(ThemeEntity).filter(ThemeEntity.id == theme_id, ThemeEntity.is_active == True).first()
        if not theme:
            return JSONResponse(
                status_code=404,
                content={
                    "message": "Theme not found",
                    "data": None
                }
            )
        
        levels = db.query(LevelEntity).filter(
            LevelEntity.theme_id == theme_id,
            LevelEntity.is_active == True
        ).order_by(LevelEntity.order_index).all()
        
        level_list = [level.to_dict() for level in levels]
        
        return JSONResponse(
            status_code=200,
            content={
                "message": "Levels retrieved successfully",
                "data": level_list
            }
        )
    except Exception as e:
        logger.error(f"Error getting levels for theme {theme_id}: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={
                "message": "Internal server error",
                "error": str(e)
            }
        )

@router.get("/level/{level_id}")
def get_level_by_id(level_id: str, db: Session = Depends(get_db)):
    """Get a specific level by ID with its questions (for quiz)"""
    try:
        level = db.query(LevelEntity).filter(LevelEntity.id == level_id, LevelEntity.is_active == True).first()
        
        if not level:
            return JSONResponse(
                status_code=404,
                content={
                    "message": "Level not found",
                    "data": None
                }
            )
        
        # Get questions for this level (without correct answers for quiz)
        questions = db.query(QuestionEntity).filter(
            QuestionEntity.level_id == level_id,
            QuestionEntity.is_active == True
        ).order_by(QuestionEntity.order_index).all()
        
        # Format questions for quiz (without correct answers)
        quiz_questions = []
        for question in questions:
            quiz_questions.append({
                "id": question.id,
                "question_text": question.question_text,
                "option_a": question.option_a,
                "option_b": question.option_b,
                "option_c": question.option_c,
                "option_d": question.option_d,
                "points": question.points
            })
        
        level_data = {
            "id": level.id,
            "title": level.title,
            "description": level.description,
            "difficulty": level.difficulty,
            "questions": quiz_questions
        }
        
        return JSONResponse(
            status_code=200,
            content={
                "message": "Level retrieved successfully",
                "data": level_data
            }
        )
    except Exception as e:
        logger.error(f"Error getting level {level_id}: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={
                "message": "Internal server error",
                "error": str(e)
            }
        )

@router.post("/level")
def create_level(level: LevelCreate, db: Session = Depends(get_db)):
    """Create a new level"""
    try:
        # Check if theme exists
        theme = db.query(ThemeEntity).filter(ThemeEntity.id == level.theme_id).first()
        if not theme:
            return JSONResponse(
                status_code=404,
                content={
                    "message": "Theme not found",
                    "data": None
                }
            )
        
        new_level = LevelEntity(
            id=str(uuid.uuid4()),
            theme_id=level.theme_id,
            title=level.title,
            description=level.description,
            difficulty=level.difficulty,
            order_index=level.order_index,
            is_active=level.is_active,
            min_score_to_unlock=level.min_score_to_unlock
        )
        
        db.add(new_level)
        db.commit()
        db.refresh(new_level)
        
        return JSONResponse(
            status_code=201,
            content={
                "message": "Level created successfully",
                "data": new_level.to_dict()
            }
        )
    except Exception as e:
        logger.error(f"Error creating level: {str(e)}")
        db.rollback()
        return JSONResponse(
            status_code=500,
            content={
                "message": "Error creating level",
                "error": str(e)
            }
        )

@router.get("/{level_id}/questions")
def get_level_questions(level_id: str, db: Session = Depends(get_db)):
    """Get all questions for a specific level"""
    try:
        # Verify level exists
        level = db.query(LevelEntity).filter(
            LevelEntity.id == level_id,
            LevelEntity.is_active == True
        ).first()
        
        if not level:
            return JSONResponse(
                status_code=404,
                content={
                    "message": "Level not found",
                    "data": None
                }
            )
        
        # Get questions for this level
        questions = db.query(QuestionEntity).filter(
            QuestionEntity.level_id == level_id,
            QuestionEntity.is_active == True
        ).order_by(QuestionEntity.order_index).all()
        
        questions_list = [question.to_dict() for question in questions]
        
        return JSONResponse(
            status_code=200,
            content={
                "message": "Level questions retrieved successfully",
                "data": questions_list
            }
        )
    except Exception as e:
        logger.error(f"Error getting level questions: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={
                "message": "Internal server error",
                "data": None
            }
        )
