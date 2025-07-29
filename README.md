# 🏛️ Civica - Plateforme d'Apprentissage du Code Électoral

## 📋 Vue d'Ensemble du Projet

**Civica** est une plateforme éducative complète dédiée à l'apprentissage du Code électoral et de la Constitution. Le projet comprend plusieurs composants interconnectés :

- **📱 Application Mobile Flutter** (`civiquizz/`) - Jeu éducatif style Candy Crush
- **🌐 Interface d'Administration React** (`Civica-Frontend/`) - Panneau d'administration web
- **🔧 API Backend FastAPI** (`Civica-Backend/`) - Serveur et base de données

---

## 🏗️ Architecture du Projet

```
Civica/
├── civiquizz/              # Application mobile Flutter
├── Civica-Frontend/        # Interface d'administration React
├── Civica-Backend/         # API Backend FastAPI
├── .gitignore
├── description.md          # Spécifications détaillées
└── README.md              # Ce fichier
```

---

## 🚀 Guide de Démarrage

### 📋 Prérequis

- **Node.js** (v12+) et **npm**
- **Python** (3.8+) et **pip**
- **Flutter SDK** (3.0+)
- **MySQL** ou **MariaDB**
- **Firebase** (pour l'app mobile)

---

## 🌐 1. Interface d'Administration (Civica-Frontend)

### 📝 Description
Interface web React.js pour l'administration de la plateforme :
- Gestion des utilisateurs
- Configuration des niveaux et points requis
- Gestion des thèmes de questions
- Création et modification des questions
- Tableau de bord avec statistiques

### 🛠️ Installation et Démarrage

```bash
# Naviguer vers le dossier frontend
cd Civica-Frontend/

# Installer les dépendances
npm install

# Démarrer l'application en mode développement
npm start
# OU si npm n'est pas dans le PATH :
./node_modules/.bin/react-scripts start
```

### 🔑 Connexion Admin
- **URL** : http://localhost:3000
- **Nom d'utilisateur** : `admin`
- **Mot de passe** : `admin`

### ✨ Fonctionnalités
- ✅ Authentification sécurisée
- ✅ Gestion CRUD des utilisateurs
- ✅ Configuration des niveaux avec points
- ✅ Gestion des thèmes colorés
- ✅ Création de questions multi-choix
- ✅ Profil utilisateur et déconnexion
- ✅ Interface responsive Material-UI

---

## 🔧 2. API Backend (Civica-Backend)

### 📝 Description
API REST FastAPI pour :
- Authentification des utilisateurs
- Gestion des données (utilisateurs, questions, scores)
- Intégration Firebase
- Documentation automatique Swagger

### 🛠️ Installation et Démarrage

```bash
# Naviguer vers le dossier backend
cd Civica-Backend/

# Créer un environnement virtuel
python -m venv venv

# Activer l'environnement virtuel
# Linux/Mac :
source venv/bin/activate
# Windows :
venv\Scripts\activate

# Installer les dépendances
pip install -r requirements.txt

# Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos configurations MySQL et Firebase

# Démarrer le serveur
python app.py
```

### 🔗 Endpoints
- **API** : http://localhost:8000
- **Documentation Swagger** : http://localhost:8000/swagger
- **Base de données** : `civica_db`

### 🗄️ Configuration Base de Données

```bash
# Variables d'environnement (.env)
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=your_user
MYSQL_PASSWORD=your_password
MYSQL_DB=civica_db
```

---

## 📱 3. Application Mobile (civiquizz)

### 📝 Description
Application mobile Flutter avec gameplay style Candy Crush :
- Jeu éducatif interactif
- Système de niveaux et récompenses
- Authentification Firebase
- Progression sauvegardée

### 🛠️ Installation et Démarrage

```bash
# Naviguer vers le dossier mobile
cd civiquizz/

# Installer les dépendances Flutter
flutter pub get

# Configurer Firebase
# 1. Créer un projet Firebase
# 2. Ajouter les fichiers de configuration :
#    - android/app/google-services.json
#    - ios/Runner/GoogleService-Info.plist

# Lancer sur émulateur/appareil
flutter run

# Ou pour une plateforme spécifique :
flutter run -d android
flutter run -d ios
```

### 🎮 Fonctionnalités
- ✅ Authentification Firebase
- ✅ Gameplay interactif
- ✅ Système de progression
- ✅ Questions par thèmes
- ✅ Récompenses et achievements
- ✅ Profil utilisateur

---

## 🔄 Workflow de Développement

### 1. **Développement Backend**
```bash
cd Civica-Backend/
source venv/bin/activate
python app.py
```

### 2. **Développement Frontend**
```bash
cd Civica-Frontend/
npm start
```

### 3. **Développement Mobile**
```bash
cd civiquizz/
flutter run
```

---

## 🎯 Fonctionnalités Clés

### 🎮 Gamification
- **Système de niveaux** configurables
- **Points** gagnés par bonnes réponses
- **Progression** sauvegardée
- **Thèmes** visuels organisés

### 👥 Gestion Utilisateurs
- **Authentification** sécurisée
- **Profils** personnalisés
- **Statistiques** de progression
- **Rôles** admin/utilisateur

### 📊 Administration
- **Dashboard** avec métriques
- **CRUD** complet des données
- **Configuration** flexible
- **Interface** moderne et responsive

---

## 🛠️ Technologies Utilisées

### Frontend (React)
- **React 18** + TypeScript
- **Material-UI (MUI)** pour l'interface
- **React Router** pour la navigation
- **Context API** pour l'état global

### Backend (FastAPI)
- **FastAPI** framework Python
- **SQLAlchemy** ORM
- **MySQL** base de données
- **Firebase Admin** SDK
- **Pydantic** validation des données

### Mobile (Flutter)
- **Flutter 3.0+**
- **Firebase** (Auth, Firestore)
- **Provider** gestion d'état
- **Material Design**

---

## 📝 Notes de Développement

### 🔧 Configuration Recommandée
1. Démarrer d'abord le **Backend** (port 8000)
2. Puis le **Frontend** (port 3000)
3. Enfin l'**App Mobile** (émulateur/appareil)

### 🚨 Problèmes Courants
- **npm/npx introuvable** : Utiliser `./node_modules/.bin/react-scripts`
- **Erreurs MySQL** : Vérifier les variables d'environnement
- **Firebase** : S'assurer que les fichiers de config sont présents

### 🔄 Mise à Jour
```bash
# Frontend
cd Civica-Frontend && npm update

# Backend
cd Civica-Backend && pip install -r requirements.txt --upgrade

# Mobile
cd civiquizz && flutter pub upgrade
```

---

## 🤝 Contribution

1. **Fork** le projet
2. **Créer** une branche feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** les changements (`git commit -m 'Add AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrir** une Pull Request

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

---

## 📞 Support

Pour toute question ou problème :
- 📧 Email : support@civica.com
- 📚 Documentation : Voir `description.md`
- 🐛 Issues : GitHub Issues

---

**🎓 Civica - Apprendre la Constitution n'a jamais été aussi ludique !**
