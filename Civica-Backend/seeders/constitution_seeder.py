#!/usr/bin/env python3
"""
Seeder pour les thèmes et questions basés sur la Constitution du Cameroun
"""
import logging
from sqlalchemy.orm import Session
from models.model_themes import ThemeEntity
from models.model_level import LevelEntity
from models.model_question import QuestionEntity
from database import get_db

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def seed_constitution_data(db: Session):
    """Seeder principal pour les données de la Constitution du Cameroun"""
    try:
        logger.info("Début du seeding des données de la Constitution du Cameroun...")
        
        # Vérifier si les données existent déjà
        existing_themes = db.query(ThemeEntity).count()
        if existing_themes > 0:
            logger.info("Les données existent déjà, seeding ignoré.")
            return
        
        # Créer les thèmes principaux
        themes_data = [
            {
                "title": "Principes Fondamentaux",
                "description": "Les principes de base de la République du Cameroun",
                "icon": "⚖️",
                "color": "#3498DB",
                "levels": [
                    {
                        "title": "Niveau Débutant",
                        "description": "Questions de base sur les principes fondamentaux",
                        "difficulty": "easy",
                        "questions": [
                            {
                                "question_text": "Quelle est la dénomination officielle du Cameroun selon l'Article 1er ?",
                                "option_a": "République Unie du Cameroun",
                                "option_b": "République du Cameroun",
                                "option_c": "État du Cameroun",
                                "option_d": "Nation du Cameroun",
                                "correct_answer": "B",
                                "explanation": "Selon l'Article 1er, la République Unie du Cameroun prend la dénomination de République du Cameroun."
                            },
                            {
                                "question_text": "Quelles sont les langues officielles du Cameroun ?",
                                "option_a": "Français et Anglais",
                                "option_b": "Français seulement",
                                "option_c": "Anglais seulement",
                                "option_d": "Français, Anglais et langues nationales",
                                "correct_answer": "A",
                                "explanation": "L'Article 1er stipule que la République du Cameroun adopte l'anglais et le français comme langues officielles d'égale valeur."
                            },
                            {
                                "question_text": "Quelle est la devise de la République du Cameroun ?",
                                "option_a": "Travail-Paix-Patrie",
                                "option_b": "Paix-Travail-Patrie",
                                "option_c": "Patrie-Travail-Paix",
                                "option_d": "Unité-Travail-Progrès",
                                "correct_answer": "B",
                                "explanation": "Selon l'Article 1er, la devise de la République du Cameroun est 'Paix-Travail-Patrie'."
                            },
                            {
                                "question_text": "Quelles sont les couleurs du drapeau camerounais ?",
                                "option_a": "Vert, Rouge, Jaune",
                                "option_b": "Bleu, Blanc, Rouge",
                                "option_c": "Rouge, Jaune, Vert",
                                "option_d": "Jaune, Rouge, Vert",
                                "correct_answer": "A",
                                "explanation": "L'Article 1er précise que le drapeau est Vert, Rouge, Jaune, à trois bandes verticales d'égales dimensions."
                            },
                            {
                                "question_text": "Où se trouve le siège des institutions camerounaises ?",
                                "option_a": "Douala",
                                "option_b": "Yaoundé",
                                "option_c": "Bafoussam",
                                "option_d": "Garoua",
                                "correct_answer": "B",
                                "explanation": "L'Article 1er stipule que le siège des institutions est à Yaoundé."
                            }
                        ]
                    },
                    {
                        "title": "Niveau Intermédiaire",
                        "description": "Questions avancées sur les principes fondamentaux",
                        "difficulty": "medium",
                        "questions": [
                            {
                                "question_text": "Selon l'Article 2, à qui appartient la souveraineté nationale ?",
                                "option_a": "Au Président",
                                "option_b": "Au Parlement",
                                "option_c": "Au peuple camerounais",
                                "option_d": "Au Gouvernement",
                                "correct_answer": "C",
                                "explanation": "L'Article 2 stipule que la souveraineté nationale appartient au peuple camerounais."
                            },
                            {
                                "question_text": "Quel est l'âge minimum pour participer au vote ?",
                                "option_a": "18 ans",
                                "option_b": "20 ans",
                                "option_c": "21 ans",
                                "option_d": "25 ans",
                                "correct_answer": "B",
                                "explanation": "Selon l'Article 2, participent au vote tous les citoyens âgés d'au moins vingt (20) ans."
                            }
                        ]
                    }
                ]
            },
            {
                "title": "Pouvoir Exécutif",
                "description": "Le Président de la République et le Gouvernement",
                "icon": "🏛️",
                "color": "#E74C3C",
                "levels": [
                    {
                        "title": "Niveau Débutant",
                        "description": "Questions de base sur le pouvoir exécutif",
                        "difficulty": "easy",
                        "questions": [
                            {
                                "question_text": "Qui est le Chef de l'État selon la Constitution ?",
                                "option_a": "Le Premier Ministre",
                                "option_b": "Le Président de la République",
                                "option_c": "Le Président de l'Assemblée",
                                "option_d": "Le Ministre de la Justice",
                                "correct_answer": "B",
                                "explanation": "L'Article 5 stipule que le Président de la République est le Chef de l'État."
                            },
                            {
                                "question_text": "Pour combien d'années le Président est-il élu ?",
                                "option_a": "5 ans",
                                "option_b": "6 ans",
                                "option_c": "7 ans",
                                "option_d": "8 ans",
                                "correct_answer": "C",
                                "explanation": "Selon l'Article 6, le Président de la République est élu pour un mandat de sept (7) ans."
                            },
                            {
                                "question_text": "Quel est l'âge minimum pour être candidat à la Présidence ?",
                                "option_a": "30 ans",
                                "option_b": "35 ans",
                                "option_c": "40 ans",
                                "option_d": "45 ans",
                                "correct_answer": "B",
                                "explanation": "L'Article 6 précise que les candidats doivent avoir trente-cinq (35) ans révolus à la date de l'élection."
                            }
                        ]
                    }
                ]
            },
            {
                "title": "Pouvoir Législatif",
                "description": "Le Parlement : Assemblée Nationale et Sénat",
                "icon": "🏛️",
                "color": "#27AE60",
                "levels": [
                    {
                        "title": "Niveau Débutant",
                        "description": "Questions de base sur le pouvoir législatif",
                        "difficulty": "easy",
                        "questions": [
                            {
                                "question_text": "Combien de chambres compose le Parlement camerounais ?",
                                "option_a": "1",
                                "option_b": "2",
                                "option_c": "3",
                                "option_d": "4",
                                "correct_answer": "B",
                                "explanation": "L'Article 14 précise que le Parlement comprend deux (2) chambres : l'Assemblée Nationale et le Sénat."
                            },
                            {
                                "question_text": "Combien de députés compose l'Assemblée Nationale ?",
                                "option_a": "150",
                                "option_b": "180",
                                "option_c": "200",
                                "option_d": "250",
                                "correct_answer": "B",
                                "explanation": "L'Article 15 stipule que l'Assemblée Nationale est composée de cent quatre-vingt (180) députés."
                            }
                        ]
                    }
                ]
            },
            {
                "title": "Pouvoir Judiciaire",
                "description": "L'organisation de la justice au Cameroun",
                "icon": "⚖️",
                "color": "#9B59B6",
                "levels": [
                    {
                        "title": "Niveau Débutant",
                        "description": "Questions de base sur le pouvoir judiciaire",
                        "difficulty": "easy",
                        "questions": [
                            {
                                "question_text": "Au nom de qui la justice est-elle rendue au Cameroun ?",
                                "option_a": "Du Président",
                                "option_b": "Du peuple camerounais",
                                "option_c": "De l'État",
                                "option_d": "Du Gouvernement",
                                "correct_answer": "B",
                                "explanation": "L'Article 37 stipule que la justice est rendue au nom du peuple camerounais."
                            }
                        ]
                    }
                ]
            },
            {
                "title": "Collectivités Territoriales",
                "description": "Les régions et communes du Cameroun",
                "icon": "🗺️",
                "color": "#F39C12",
                "levels": [
                    {
                        "title": "Niveau Débutant",
                        "description": "Questions de base sur les collectivités territoriales",
                        "difficulty": "easy",
                        "questions": [
                            {
                                "question_text": "Combien de régions compte le Cameroun selon la Constitution ?",
                                "option_a": "8",
                                "option_b": "10",
                                "option_c": "12",
                                "option_d": "15",
                                "correct_answer": "B",
                                "explanation": "L'Article 61 énumère 10 régions : Adamaoua, Centre, Est, Extrême Nord, Littoral, Nord, Nord-Ouest, Ouest, Sud, Sud-Ouest."
                            }
                        ]
                    }
                ]
            }
        ]
        
        # Créer les thèmes, niveaux et questions
        for theme_data in themes_data:
            # Créer le thème
            theme = ThemeEntity(
                title=theme_data["title"],
                description=theme_data["description"],
                icon=theme_data["icon"],
                color=theme_data["color"]
            )
            db.add(theme)
            db.flush()  # Pour obtenir l'ID du thème
            
            logger.info(f"Thème créé: {theme.title}")
            
            # Créer les niveaux pour ce thème
            for level_data in theme_data["levels"]:
                level = LevelEntity(
                    title=level_data["title"],
                    description=level_data["description"],
                    difficulty=level_data["difficulty"],
                    theme_id=theme.id
                )
                db.add(level)
                db.flush()  # Pour obtenir l'ID du niveau
                
                logger.info(f"  Niveau créé: {level.title}")
                
                # Créer les questions pour ce niveau
                for question_data in level_data["questions"]:
                    question = QuestionEntity(
                        question_text=question_data["question_text"],
                        option_a=question_data["option_a"],
                        option_b=question_data["option_b"],
                        option_c=question_data["option_c"],
                        option_d=question_data["option_d"],
                        correct_answer=question_data["correct_answer"],
                        explanation=question_data["explanation"],
                        level_id=level.id
                    )
                    db.add(question)
                    
                logger.info(f"    {len(level_data['questions'])} questions créées")
        
        # Sauvegarder toutes les modifications
        db.commit()
        logger.info("Seeding des données de la Constitution terminé avec succès!")
        
    except Exception as e:
        logger.error(f"Erreur lors du seeding: {str(e)}")
        db.rollback()
        raise

def run_seeder():
    """Point d'entrée pour exécuter le seeder"""
    db = next(get_db())
    try:
        seed_constitution_data(db)
    finally:
        db.close()

if __name__ == "__main__":
    run_seeder()
