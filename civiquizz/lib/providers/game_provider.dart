import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/theme_model.dart';
import '../models/level_model.dart';
import '../services/database_service.dart';

class GameProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<ThemeModel> _themes = [];
  List<LevelModel> _currentLevels = [];
  List<QuestionModel> _currentQuestions = [];
  Map<String, dynamic> _userProgress = {};
  
  // État du jeu actuel
  LevelModel? _currentLevel;
  int _currentQuestionIndex = 0;
  int _currentScore = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  bool _isGameActive = false;
  bool _isLoading = false;

  // Getters
  List<ThemeModel> get themes => _themes;
  List<LevelModel> get currentLevels => _currentLevels;
  List<QuestionModel> get currentQuestions => _currentQuestions;
  Map<String, dynamic> get userProgress => _userProgress;
  LevelModel? get currentLevel => _currentLevel;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get currentScore => _currentScore;
  int get correctAnswers => _correctAnswers;
  int get totalQuestions => _totalQuestions;
  bool get isGameActive => _isGameActive;
  bool get isLoading => _isLoading;
  
  QuestionModel? get currentQuestion {
    if (_currentQuestions.isNotEmpty && 
        _currentQuestionIndex < _currentQuestions.length) {
      return _currentQuestions[_currentQuestionIndex];
    }
    return null;
  }

  bool get isLastQuestion => _currentQuestionIndex >= _currentQuestions.length - 1;
  
  double get progressPercentage {
    if (_totalQuestions == 0) return 0.0;
    return (_currentQuestionIndex + 1) / _totalQuestions;
  }

  // Initialiser les données du jeu
  Future<void> initializeGameData() async {
    _setLoading(true);
    try {
      await _databaseService.initializeBaseData();
      await loadThemes();
    } catch (e) {
      print('Erreur lors de l\'initialisation des données du jeu: $e');
    }
    _setLoading(false);
  }

  // Charger tous les thèmes
  Future<void> loadThemes() async {
    try {
      _themes = await _databaseService.getThemes();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des thèmes: $e');
    }
  }

  // Charger les niveaux d'un thème
  Future<void> loadLevelsByTheme(String themeId) async {
    _setLoading(true);
    try {
      _currentLevels = await _databaseService.getLevelsByTheme(themeId);
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des niveaux: $e');
    }
    _setLoading(false);
  }

  // Charger la progression de l'utilisateur
  Future<void> loadUserProgress(String userId) async {
    try {
      _userProgress = await _databaseService.getUserProgress(userId);
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement de la progression: $e');
    }
  }

  // Démarrer un niveau
  Future<bool> startLevel(LevelModel level) async {
    _setLoading(true);
    try {
      _currentLevel = level;
      _currentQuestions = await _databaseService.getQuestionsByLevel(level.questionIds);
      
      if (_currentQuestions.isEmpty) {
        // Si pas de questions spécifiques, charger par thème et niveau
        ThemeModel? theme = _themes.firstWhere(
          (t) => t.id == level.themeId,
          orElse: () => _themes.first,
        );
        _currentQuestions = await _databaseService.getQuestionsByThemeAndLevel(
          theme.nom, 
          level.numero,
        );
      }

      if (_currentQuestions.isNotEmpty) {
        _currentQuestions.shuffle(); // Mélanger les questions
        _resetGameState();
        _totalQuestions = _currentQuestions.length;
        _isGameActive = true;
        _setLoading(false);
        return true;
      }
    } catch (e) {
      print('Erreur lors du démarrage du niveau: $e');
    }
    _setLoading(false);
    return false;
  }

  // Répondre à une question
  bool answerQuestion(String selectedAnswer) {
    if (!_isGameActive || currentQuestion == null) return false;

    bool isCorrect = selectedAnswer == currentQuestion!.reponse;
    
    if (isCorrect) {
      _correctAnswers++;
      _currentScore += currentQuestion!.points;
    }

    notifyListeners();
    return isCorrect;
  }

  // Passer à la question suivante
  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Terminer le niveau
  Future<Map<String, dynamic>> finishLevel(String userId) async {
    if (!_isGameActive || _currentLevel == null) {
      return {'success': false, 'message': 'Aucun niveau actif'};
    }

    try {
      // Calculer les étoiles (0-3)
      double percentage = _correctAnswers / _totalQuestions;
      int etoiles = 0;
      if (percentage >= 0.9) etoiles = 3;
      else if (percentage >= 0.7) etoiles = 2;
      else if (percentage >= 0.5) etoiles = 1;

      bool isCompleted = etoiles > 0;

      // Sauvegarder la progression
      await _databaseService.saveLevelProgress(
        userId,
        _currentLevel!.id,
        isCompleted: isCompleted,
        etoiles: etoiles,
        score: _currentScore,
      );

      // Mettre à jour la progression locale
      _userProgress[_currentLevel!.id] = {
        'levelId': _currentLevel!.id,
        'isCompleted': isCompleted,
        'etoiles': etoiles,
        'score': _currentScore,
        'completedAt': DateTime.now().toIso8601String(),
      };

      _isGameActive = false;
      notifyListeners();

      return {
        'success': true,
        'etoiles': etoiles,
        'score': _currentScore,
        'correctAnswers': _correctAnswers,
        'totalQuestions': _totalQuestions,
        'percentage': (percentage * 100).round(),
      };
    } catch (e) {
      print('Erreur lors de la finalisation du niveau: $e');
      return {'success': false, 'message': 'Erreur lors de la sauvegarde'};
    }
  }

  // Abandonner le niveau
  void quitLevel() {
    _resetGameState();
    _isGameActive = false;
    _currentLevel = null;
    notifyListeners();
  }

  // Vérifier si un niveau est débloqué
  bool isLevelUnlocked(LevelModel level) {
    if (level.numero == 1) return true; // Premier niveau toujours débloqué
    
    // Vérifier si le niveau précédent est complété
    LevelModel? previousLevel = _currentLevels
        .where((l) => l.themeId == level.themeId && l.numero == level.numero - 1)
        .firstOrNull;
    
    if (previousLevel != null) {
      var progress = _userProgress[previousLevel.id];
      return progress != null && progress['isCompleted'] == true;
    }
    
    return false;
  }

  // Obtenir les étoiles d'un niveau
  int getLevelStars(String levelId) {
    var progress = _userProgress[levelId];
    return progress?['etoiles'] ?? 0;
  }

  // Vérifier si un niveau est complété
  bool isLevelCompleted(String levelId) {
    var progress = _userProgress[levelId];
    return progress?['isCompleted'] ?? false;
  }

  // Réinitialiser l'état du jeu
  void _resetGameState() {
    _currentQuestionIndex = 0;
    _currentScore = 0;
    _correctAnswers = 0;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
