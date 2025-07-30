import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/theme_model.dart';
import '../models/level_model.dart';

class GameProvider with ChangeNotifier {
  
  List<ThemeModel> _themes = [];
  List<LevelModel> _currentLevels = [];
  List<QuestionModel> _currentQuestions = [];
  final Map<String, dynamic> _userProgress = {};
  
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

  // Méthodes simplifiées - les données viennent maintenant de ThemeProvider
  void setThemes(List<ThemeModel> themes) {
    _themes = themes;
    notifyListeners();
  }

  void setCurrentLevels(List<LevelModel> levels) {
    _currentLevels = levels;
    notifyListeners();
  }

  // Démarrer un niveau
  Future<bool> startLevel(LevelModel level) async {
    _setLoading(true);
    try {
      _currentLevel = level;
      // Utiliser les questions déjà chargées dans le niveau
      _currentQuestions = level.questions ?? [];
      
      if (_currentQuestions.isEmpty) {
        debugPrint('Aucune question trouvée pour ce niveau');
        _setLoading(false);
        return false;
      }

      // Mélanger les questions
      _currentQuestions.shuffle();
      _resetGameState();
      _totalQuestions = _currentQuestions.length;
      _isGameActive = true;
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Erreur lors du démarrage du niveau: $e');
    }
    _setLoading(false);
    return false;
  }

  // Répondre à une question
  bool answerQuestion(String selectedAnswer) {
    if (!_isGameActive || currentQuestion == null) return false;

    bool isCorrect = selectedAnswer == currentQuestion!.correctAnswer;
    
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

  // Finaliser le niveau (version simplifiée)
  Map<String, dynamic> finishLevel() {
    if (_currentLevel == null) {
      return {'success': false, 'message': 'Aucun niveau actif'};
    }

    double percentage = _correctAnswers / _totalQuestions;
    String grade = _calculateGrade(percentage);

    _isGameActive = false;
    notifyListeners();

    return {
      'score': _currentScore,
      'correctAnswers': _correctAnswers,
      'totalQuestions': _totalQuestions,
      'percentage': (percentage * 100).round(),
      'grade': grade,
    };
  }

  String _calculateGrade(double percentage) {
    if (percentage >= 0.95) return 'A+';
    if (percentage >= 0.85) return 'A';
    if (percentage >= 0.75) return 'B';
    if (percentage >= 0.65) return 'C';
    if (percentage >= 0.50) return 'D';
    return 'F';
  }

  // Abandonner le niveau
  void quitLevel() {
    _resetGameState();
    _isGameActive = false;
    _currentLevel = null;
    notifyListeners();
  }

  // Méthodes simplifiées pour la compatibilité
  bool isLevelUnlocked(LevelModel level) {
    // Pour l'instant, tous les niveaux sont débloqués
    return true;
  }

  bool isLevelCompleted(String levelId) {
    // Vérifier dans la progression locale
    return _userProgress.containsKey(levelId);
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
