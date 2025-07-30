
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
    prefix="/api/question",
    tags=["Question"],
    responses={404: {"description": "Not found"}},
)
# QUESTION ENDPOINTS

@router.get("/")
def get_questions(db: Session = Depends(get_db)):
    """Get all questions"""
    try:
        questions = db.query(QuestionEntity).filter(QuestionEntity.is_active == True).order_by(QuestionEntity.order_index).all()
        question_list = [question.to_dict() for question in questions]
        return JSONResponse(
            status_code=200,
            content={
                "message": "Questions retrieved successfully",
                "data": question_list
            }
        )
    except Exception as e:
        logger.error(f"Error getting questions: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={
                "message": "Internal server error",
                "error": str(e)
            }
        )

@router.post("/question")
def create_question(question: QuestionCreate, db: Session = Depends(get_db)):
    """Create a new question"""
    try:
        # Check if level exists
        level = db.query(LevelEntity).filter(LevelEntity.id == question.level_id).first()
        if not level:
            return JSONResponse(
                status_code=404,
                content={
                    "message": "Level not found",
                    "data": None
                }
            )
        
        # Validate correct answer
        if question.correct_answer not in ['A', 'B', 'C', 'D']:
            return JSONResponse(
                status_code=400,
                content={
                    "message": "Correct answer must be A, B, C, or D",
                    "data": None
                }
            )
        
        new_question = QuestionEntity(
            id=str(uuid.uuid4()),
            level_id=question.level_id,
            question_text=question.question_text,
            option_a=question.option_a,
            option_b=question.option_b,
            option_c=question.option_c,
            option_d=question.option_d,
            correct_answer=question.correct_answer,
            explanation=question.explanation,
            points=question.points,
            order_index=question.order_index,
            is_active=question.is_active
        )
        
        db.add(new_question)
        db.commit()
        db.refresh(new_question)
        
        return JSONResponse(
            status_code=201,
            content={
                "message": "Question created successfully",
                "data": new_question.to_dict()
            }
        )
    except Exception as e:
        logger.error(f"Error creating question: {str(e)}")
        db.rollback()
        return JSONResponse(
            status_code=500,
            content={
                "message": "Error creating question",
                "error": str(e)
            }
        )

@router.post("/question/{question_id}/answer")
def check_answer(question_id: str, answer: dict, db: Session = Depends(get_db)):
    """Check if the provided answer is correct"""
    try:
        question = db.query(QuestionEntity).filter(QuestionEntity.id == question_id).first()
        
        if not question:
            return JSONResponse(
                status_code=404,
                content={
                    "message": "Question not found",
                    "data": None
                }
            )
        
        user_answer = answer.get('answer', '').upper()
        is_correct = user_answer == question.correct_answer
        
        response_data = {
            "is_correct": is_correct,
            "correct_answer": question.correct_answer,
            "explanation": question.explanation,
            "points_earned": question.points if is_correct else 0
        }
        
        return JSONResponse(
            status_code=200,
            content={
                "message": "Answer checked successfully",
                "data": response_data
            }
        )
    except Exception as e:
        logger.error(f"Error checking answer for question {question_id}: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={
                "message": "Internal server error",
                "error": str(e)
            }
        )
