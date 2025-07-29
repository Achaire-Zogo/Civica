# 📱 Application Mobile : **Civiquizz - Le Jeu de la Constitution**

## 🎯 Objectif

Développer une application mobile éducative de type **jeu vidéo** inspirée de Candy Crush, visant à tester et améliorer la **connaissance de la Constitution et du Code électoral**.  
L'application est **intuitive**, **interactive** et **gamifiée**, avec des **niveaux**, un **système de récompenses**, et une **authentification utilisateur**.

---

## ⚙️ Technologies

- **Flutter** (cross-platform mobile app)
- **Firebase** (authentification, base de données, stockage de progression)
- **Provider** ou **Riverpod** (gestion d’état)
- **Gamification Engine** (à implémenter selon la logique de niveaux/récompenses)

---

## 🧩 Fonctionnalités Clés

### 🔐 Authentification
- Création de compte (e-mail / mot de passe)
- Connexion
- Réinitialisation du mot de passe
- Gestion de profil utilisateur

### 🎮 Gameplay (Style Candy Crush)
- Système de niveaux avec grille interactive
- Chaque niveau = un ensemble de questions/réponses
- Interactions similaires à Candy Crush (glisser pour relier des réponses, faire apparaître des quiz en cliquant, etc.)
- Difficulté progressive

### 🧠 Quiz Constitutionnel
- Base de questions-réponses sur :
  - La Constitution
  - Le Code électoral
- Catégories thématiques (Droits fondamentaux, Institutions, Élections, etc.)
- Types de questions :
  - QCM
  - Vrai/Faux
  - Texte à trous

### 🏆 Récompenses et progression
- Points d’expérience (XP)
- Badges
- Déblocage de niveaux
- Système de vies (nombre d’essais/jour)
- Boutique virtuelle avec récompenses (facultatif)

### 📊 Tableau de Bord
- Score global
- Progrès par chapitre
- Historique des niveaux complétés

---

## 🧠 Architecture de Données (exemple simplifié)

### Utilisateur
```json
{
  "uid": "string",
  "email": "string",
  "pseudo": "string",
  "score": 1200,
  "niveau": 5,
  "badges": ["Débutant", "Citoyen Actif"],
  "vies": 3
}
```

### Question
{
  "id": "string",
  "texte": "Quelle est la durée du mandat présidentiel ?",
  "options": ["4 ans", "5 ans", "6 ans", "7 ans"],
  "réponse": "7 ans",
  "niveau": 3,
  "thème": "Présidence"
}

### theme
{
  "id": "string",
  "nom": "Présidence",
  "description": "Thème de la présidence"
}

### Niveau
{
  "id": "string",
  "nom": "Niveau 1",
  "description": "Niveau 1"
}