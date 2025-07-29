# 📱 Civiquizz - Le Jeu de la Constitution

Une application mobile éducative gamifiée pour apprendre la Constitution française et le Code électoral de manière ludique et interactive.

## 🎯 Objectif

Civiquizz est une application mobile de type jeu vidéo inspirée de Candy Crush, conçue pour tester et améliorer la **connaissance de la Constitution et du Code électoral**. L'application est **intuitive**, **interactive** et **gamifiée**, avec des **niveaux**, un **système de récompenses**, et une **authentification utilisateur**.

## ⚙️ Technologies Utilisées

- **Flutter** - Framework cross-platform pour le développement mobile
- **Firebase** - Authentification, base de données et stockage
- **Provider** - Gestion d'état
- **Google Fonts** - Typographie moderne
- **Material Design 3** - Interface utilisateur moderne

## 🧩 Fonctionnalités Principales

### 🔐 Authentification
- ✅ Création de compte (email/mot de passe)
- ✅ Connexion sécurisée
- ✅ Réinitialisation du mot de passe
- ✅ Gestion de profil utilisateur

### 🎮 Gameplay
- ✅ Système de niveaux progressifs
- ✅ Interface inspirée des jeux mobiles populaires
- ✅ Questions interactives avec feedback visuel
- ✅ Système de vies (3 vies maximum, rechargement automatique)
- ✅ Animations et transitions fluides

### 🧠 Quiz Constitutionnel
- ✅ Base de questions sur la Constitution française
- ✅ Questions sur le Code électoral
- ✅ Catégories thématiques (Droits fondamentaux, Institutions, Élections)
- ✅ Types de questions variés :
  - QCM (Questions à Choix Multiples)
  - Vrai/Faux
  - Support pour texte à trous (extensible)

### 🏆 Système de Récompenses
- ✅ Points d'expérience (XP)
- ✅ Système de badges
- ✅ Déblocage progressif des niveaux
- ✅ Système d'étoiles (0-3 par niveau)
- ✅ Suivi de la progression

### 📊 Tableau de Bord
- ✅ Score global de l'utilisateur
- ✅ Progrès par thème et niveau
- ✅ Historique des niveaux complétés
- ✅ Affichage des badges obtenus

## 🏗️ Architecture de l'Application

### Structure des Dossiers
```
lib/
├── data/           # Données d'exemple et configuration
├── models/         # Modèles de données (User, Question, Theme, Level)
├── providers/      # Gestion d'état avec Provider
├── screens/        # Écrans de l'application
│   ├── auth/       # Authentification (Login, Register)
│   ├── game/       # Jeu (Themes, Levels, Quiz, Results)
│   ├── home/       # Écran d'accueil
│   └── profile/    # Profil utilisateur
├── services/       # Services (Auth, Database)
├── utils/          # Utilitaires
└── widgets/        # Widgets réutilisables
```

### Modèles de Données

#### Utilisateur
```dart
class UserModel {
  final String uid;
  final String email;
  final String pseudo;
  final int score;
  final int niveau;
  final List<String> badges;
  final int vies;
  final DateTime? lastLifeRefresh;
  final Map<String, dynamic>? progression;
}
```

#### Question
```dart
class QuestionModel {
  final String id;
  final String texte;
  final List<String> options;
  final String reponse;
  final int niveau;
  final String theme;
  final QuestionType type;
  final int points;
  final String? explication;
}
```

## 🚀 Installation et Configuration

### Prérequis
- Flutter SDK (>=3.5.4)
- Dart SDK
- Firebase CLI
- Un projet Firebase configuré

### Installation

1. **Cloner le repository**
```bash
git clone https://github.com/votre-username/civiquizz.git
cd civiquizz
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configuration Firebase**
   - Créer un projet Firebase sur [Firebase Console](https://console.firebase.google.com/)
   - Activer Authentication (Email/Password)
   - Activer Cloud Firestore
   - Télécharger les fichiers de configuration :
     - `google-services.json` pour Android (dans `android/app/`)
     - `GoogleService-Info.plist` pour iOS (dans `ios/Runner/`)
   - Mettre à jour `lib/firebase_options.dart` avec vos clés API

4. **Lancer l'application**
```bash
flutter run
```

## 🎮 Guide d'Utilisation

### Pour les Utilisateurs

1. **Inscription/Connexion**
   - Créer un compte avec email et mot de passe
   - Choisir un pseudo unique

2. **Navigation**
   - **Accueil** : Vue d'ensemble des statistiques
   - **Jouer** : Sélection des thèmes et niveaux
   - **Profil** : Gestion du compte et badges

3. **Gameplay**
   - Sélectionner un thème débloqué
   - Choisir un niveau accessible
   - Répondre aux questions dans le temps imparti
   - Gagner des étoiles selon les performances

### Système de Progression
- **Vies** : 3 vies maximum, rechargement automatique (1 vie toutes les 2h)
- **Étoiles** : 0-3 étoiles par niveau selon le pourcentage de bonnes réponses
  - 1 étoile : 50-69% de bonnes réponses
  - 2 étoiles : 70-89% de bonnes réponses
  - 3 étoiles : 90-100% de bonnes réponses
- **Badges** : Débloqués selon les achievements

## 🛠️ Développement

### Ajouter de Nouvelles Questions

1. Modifier `lib/data/sample_data.dart`
2. Ajouter les questions dans `getSampleQuestions()`
3. Mettre à jour Firebase avec les nouvelles données

### Ajouter de Nouveaux Thèmes

1. Créer le thème dans `getSampleThemes()`
2. Créer les niveaux correspondants dans `getSampleLevels()`
3. Ajouter les questions associées

### Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter drive --target=test_driver/app.dart
```

## 📱 Captures d'Écran

*Note: Ajoutez ici des captures d'écran de l'application*

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👥 Équipe

- **Développement** : Équipe Civiquizz
- **Design UI/UX** : Material Design 3
- **Contenu éducatif** : Questions basées sur la Constitution française officielle

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Contacter l'équipe de développement

---

**Civiquizz** - Apprendre la Constitution n'a jamais été aussi amusant ! 🎓📚
