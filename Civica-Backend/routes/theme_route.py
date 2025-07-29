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
    prefix="/api/theme",
    tags=["Theme"],
    responses={404: {"description": "Not found"}},
)

# THEME ENDPOINTS

@router.get("/")
def get_all_themes(db: Session = Depends(get_db)):
    """Get all active themes with their levels count"""
    try:
        themes = db.query(ThemeEntity).filter(ThemeEntity.is_active == True).order_by(ThemeEntity.order_index).all()
        theme_list = [theme.to_dict() for theme in themes]
        
        return JSONResponse(
            status_code=200,
            content={
                "message": "Themes retrieved successfully",
                "data": theme_list
            }
        )
    except Exception as e:
        logger.error(f"Error getting themes: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={
                "message": "Internal server error",
                "error": str(e)
            }
        )

@router.get("/{theme_id}")
def get_theme_by_id(theme_id: str, db: Session = Depends(get_db)):
    """Get a specific theme by ID with its levels"""
    try:
        theme = db.query(ThemeEntity).filter(ThemeEntity.id == theme_id, ThemeEntity.is_active == True).first()
        
        if not theme:
            return JSONResponse(
                status_code=404,
                content={
                    "message": "Theme not found",
                    "data": None
                }
            )
        
        # Get levels for this theme
        levels = db.query(LevelEntity).filter(
            LevelEntity.theme_id == theme_id,
            LevelEntity.is_active == True
        ).order_by(LevelEntity.order_index).all()
        
        theme_data = theme.to_dict()
        theme_data['levels'] = [level.to_dict() for level in levels]
        
        return JSONResponse(
            status_code=200,
            content={
                "message": "Theme retrieved successfully",
                "data": theme_data
            }
        )
    except Exception as e:
        logger.error(f"Error getting theme {theme_id}: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={
                "message": "Internal server error",
                "error": str(e)
            }
        )

@router.post("/")
def create_theme(theme: ThemeCreate, db: Session = Depends(get_db)):
    """Create a new theme"""
    try:
        new_theme = ThemeEntity(
            id=str(uuid.uuid4()),
            title=theme.title,
            description=theme.description,
            icon=theme.icon,
            color=theme.color,
            is_active=theme.is_active,
            order_index=theme.order_index
        )
        
        db.add(new_theme)
        db.commit()
        db.refresh(new_theme)
        
        return JSONResponse(
            status_code=201,
            content={
                "message": "Theme created successfully",
                "data": new_theme.to_dict()
            }
        )
    except Exception as e:
        logger.error(f"Error creating theme: {str(e)}")
        db.rollback()
        return JSONResponse(
            status_code=500,
            content={
                "message": "Error creating theme",
                "error": str(e)
            }
        )

@router.put("/{theme_id}")
def update_theme(theme_id: str, theme: ThemeUpdate, db: Session = Depends(get_db)):
    """Update an existing theme"""
    try:
        db_theme = db.query(ThemeEntity).filter(ThemeEntity.id == theme_id).first()
        
        if not db_theme:
            return JSONResponse(
                status_code=404,
                content={
                    "message": "Theme not found",
                    "data": None
                }
            )
        
        # Update fields if provided
        if theme.title is not None:
            db_theme.title = theme.title
        if theme.description is not None:
            db_theme.description = theme.description
        if theme.icon is not None:
            db_theme.icon = theme.icon
        if theme.color is not None:
            db_theme.color = theme.color
        if theme.is_active is not None:
            db_theme.is_active = theme.is_active
        if theme.order_index is not None:
            db_theme.order_index = theme.order_index
        
        db_theme.updated_at = datetime.utcnow()
        db.commit()
        db.refresh(db_theme)
        
        return JSONResponse(
            status_code=200,
            content={
                "message": "Theme updated successfully",
                "data": db_theme.to_dict()
            }
        )
    except Exception as e:
        logger.error(f"Error updating theme {theme_id}: {str(e)}")
        db.rollback()
        return JSONResponse(
            status_code=500,
            content={
                "message": "Error updating theme",
                "error": str(e)
            }
        )

@router.delete("/{theme_id}")
def delete_theme(theme_id: str, db: Session = Depends(get_db)):
    """Soft delete a theme (set is_active to False)"""
    try:
        db_theme = db.query(ThemeEntity).filter(ThemeEntity.id == theme_id).first()
        
        if not db_theme:
            return JSONResponse(
                status_code=404,
                content={
                    "message": "Theme not found",
                    "data": None
                }
            )
        
        db_theme.is_active = False
        db_theme.updated_at = datetime.utcnow()
        db.commit()
        
        return JSONResponse(
            status_code=200,
            content={
                "message": "Theme deleted successfully",
                "data": None
            }
        )
    except Exception as e:
        logger.error(f"Error deleting theme {theme_id}: {str(e)}")
        db.rollback()
        return JSONResponse(
            status_code=500,
            content={
                "message": "Error deleting theme",
                "error": str(e)
            }
        )



# UTILITY ENDPOINTS

@router.post("/seed-data")
def seed_sample_data(db: Session = Depends(get_db)):
    """Seed the database with sample themes, levels, and questions"""
    try:
        # Check if data already exists
        existing_themes = db.query(ThemeEntity).count()
        if existing_themes > 0:
            return JSONResponse(
                status_code=200,
                content={
                    "message": "Sample data already exists",
                    "data": None
                }
            )
        
        # Create sample themes
        themes_data = [
            {
                "title": "Constitution Française",
                "description": "Découvrez les fondements de la Constitution française",
                "icon": "gavel",
                "color": "#3498DB",
                "order_index": 1
            },
            {
                "title": "Droits et Libertés",
                "description": "Explorez vos droits et libertés fondamentaux",
                "icon": "balance_scale",
                "color": "#E74C3C",
                "order_index": 2
            },
            {
                "title": "Institutions Républicaines",
                "description": "Comprenez le fonctionnement des institutions",
                "icon": "account_balance",
                "color": "#2ECC71",
                "order_index": 3
            }
        ]
        
        created_themes = []
        for theme_data in themes_data:
            theme = ThemeEntity(
                id=str(uuid.uuid4()),
                **theme_data
            )
            db.add(theme)
            created_themes.append(theme)
        
        db.commit()
        
        # Create sample levels for each theme
        for theme in created_themes:
            levels_data = [
                {
                    "title": f"Niveau Débutant - {theme.title}",
                    "description": f"Introduction aux concepts de base de {theme.title.lower()}",
                    "difficulty": "easy",
                    "order_index": 1
                },
                {
                    "title": f"Niveau Intermédiaire - {theme.title}",
                    "description": f"Approfondissement des concepts de {theme.title.lower()}",
                    "difficulty": "medium",
                    "order_index": 2,
                    "min_score_to_unlock": 50
                }
            ]
            
            for level_data in levels_data:
                level = LevelEntity(
                    id=str(uuid.uuid4()),
                    theme_id=theme.id,
                    **level_data
                )
                db.add(level)
        
        db.commit()
        
        return JSONResponse(
            status_code=201,
            content={
                "message": "Sample data created successfully",
                "data": f"Created {len(created_themes)} themes with levels"
            }
        )
    except Exception as e:
        logger.error(f"Error seeding sample data: {str(e)}")
        db.rollback()
        return JSONResponse(
            status_code=500,
            content={
                "message": "Error creating sample data",
                "error": str(e)
            }
        )