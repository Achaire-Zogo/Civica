import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';
import '../models/theme_model.dart';
import '../models/level_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer tous les thèmes
  Future<List<ThemeModel>> getThemes() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('themes').get();
      return snapshot.docs
          .map((doc) => ThemeModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des thèmes: $e');
      return [];
    }
  }

  // Récupérer les niveaux d'un thème
  Future<List<LevelModel>> getLevelsByTheme(String themeId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('levels')
          .where('themeId', isEqualTo: themeId)
          .orderBy('numero')
          .get();
      return snapshot.docs
          .map((doc) => LevelModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des niveaux: $e');
      return [];
    }
  }

  // Récupérer les questions d'un niveau
  Future<List<QuestionModel>> getQuestionsByLevel(List<String> questionIds) async {
    try {
      if (questionIds.isEmpty) return [];
      
      QuerySnapshot snapshot = await _firestore
          .collection('questions')
          .where(FieldPath.documentId, whereIn: questionIds)
          .get();
      return snapshot.docs
          .map((doc) => QuestionModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des questions: $e');
      return [];
    }
  }

  // Récupérer des questions par thème et niveau
  Future<List<QuestionModel>> getQuestionsByThemeAndLevel(String theme, int niveau) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('questions')
          .where('theme', isEqualTo: theme)
          .where('niveau', isEqualTo: niveau)
          .get();
      return snapshot.docs
          .map((doc) => QuestionModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des questions: $e');
      return [];
    }
  }

  // Sauvegarder la progression d'un niveau
  Future<void> saveLevelProgress(String userId, String levelId, {
    required bool isCompleted,
    required int etoiles,
    required int score,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('progression')
          .doc(levelId)
          .set({
        'levelId': levelId,
        'isCompleted': isCompleted,
        'etoiles': etoiles,
        'score': score,
        'completedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erreur lors de la sauvegarde de la progression: $e');
      rethrow;
    }
  }

  // Récupérer la progression d'un utilisateur
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progression')
          .get();
      
      Map<String, dynamic> progress = {};
      for (var doc in snapshot.docs) {
        progress[doc.id] = doc.data();
      }
      return progress;
    } catch (e) {
      print('Erreur lors de la récupération de la progression: $e');
      return {};
    }
  }

  // Ajouter un badge à un utilisateur
  Future<void> addBadgeToUser(String userId, String badge) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'badges': FieldValue.arrayUnion([badge])
      });
    } catch (e) {
      print('Erreur lors de l\'ajout du badge: $e');
      rethrow;
    }
  }

  // Initialiser les données de base (à appeler une seule fois)
  Future<void> initializeBaseData() async {
    try {
      // Vérifier si les données existent déjà
      QuerySnapshot themesSnapshot = await _firestore.collection('themes').limit(1).get();
      if (themesSnapshot.docs.isNotEmpty) {
        return; // Les données existent déjà
      }

      // Créer les thèmes de base
      List<ThemeModel> themes = [
        ThemeModel(
          id: 'constitution',
          nom: 'Constitution',
          description: 'Questions sur la Constitution française',
          icone: '📜',
          couleur: '#3498db',
          sousThemes: ['Droits fondamentaux', 'Institutions', 'Révision'],
          isUnlocked: true,
        ),
        ThemeModel(
          id: 'elections',
          nom: 'Code électoral',
          description: 'Questions sur les élections et le code électoral',
          icone: '🗳️',
          couleur: '#e74c3c',
          sousThemes: ['Élections présidentielles', 'Élections législatives', 'Élections locales'],
          isUnlocked: false,
        ),
        ThemeModel(
          id: 'institutions',
          nom: 'Institutions',
          description: 'Questions sur les institutions françaises',
          icone: '🏛️',
          couleur: '#f39c12',
          sousThemes: ['Exécutif', 'Législatif', 'Judiciaire'],
          isUnlocked: false,
        ),
      ];

      for (ThemeModel theme in themes) {
        await _firestore.collection('themes').doc(theme.id).set(theme.toJson());
      }

      print('Données de base initialisées avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation des données: $e');
      rethrow;
    }
  }
}
