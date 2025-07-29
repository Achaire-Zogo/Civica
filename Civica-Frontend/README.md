# Civica Frontend - Panneau d'Administration

Application React.js pour l'administration de la plateforme Civica.

## Fonctionnalités

- **Authentification Admin** : Connexion sécurisée pour les administrateurs
- **Gestion des Utilisateurs** : CRUD complet pour les utilisateurs
- **Gestion des Niveaux** : Configuration des niveaux avec points requis
- **Gestion des Thèmes** : Organisation des questions par thèmes
- **Gestion des Questions** : Création et modification des questions de quiz
- **Profil Utilisateur** : Gestion du profil administrateur
- **Interface Moderne** : UI responsive avec Material-UI

## Technologies

- React 18 avec TypeScript
- Material-UI (MUI) pour l'interface
- React Router pour la navigation
- Context API pour la gestion d'état

## Installation

```bash
# Installer les dépendances
npm install

# Démarrer l'application en mode développement
npm start
```

## Connexion

Utilisez les identifiants suivants pour vous connecter :
- **Nom d'utilisateur** : admin
- **Mot de passe** : admin

## Structure du Projet

```
src/
├── components/          # Composants réutilisables
│   ├── Sidebar.tsx     # Menu latéral
│   └── DashboardLayout.tsx # Layout principal
├── contexts/           # Contextes React
│   └── AuthContext.tsx # Gestion de l'authentification
├── pages/              # Pages de l'application
│   ├── LoginPage.tsx   # Page de connexion
│   ├── DashboardPage.tsx # Tableau de bord
│   ├── UsersPage.tsx   # Gestion des utilisateurs
│   ├── LevelsPage.tsx  # Gestion des niveaux
│   ├── ThemesPage.tsx  # Gestion des thèmes
│   ├── QuestionsPage.tsx # Gestion des questions
│   └── ProfilePage.tsx # Profil utilisateur
├── types/              # Types TypeScript
│   └── index.ts        # Définitions des types
└── App.tsx             # Composant principal
```

## Fonctionnement des Niveaux

Les niveaux sont configurables avec un système de points :
- Chaque niveau a un nombre de points requis
- Les utilisateurs progressent en accumulant des points
- Les points sont gagnés en répondant correctement aux questions
- L'ordre des niveaux est personnalisable

## Développement

L'application est conçue pour être facilement extensible :
- Ajout de nouveaux types de questions
- Intégration avec une API backend
- Système de notifications
- Analytics et rapports
