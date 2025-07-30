import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/level_model.dart';
import '../services/theme_service.dart';
import '../providers/auth_provider.dart';

class QuizProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  
  // Quiz state
  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  Map<int, String> _userAnswers = {};
  int _score = 0;
  int _correctAnswers = 0;
  bool _isQuizCompleted = false;
  bool _isLoading = false;
  String? _error;
  
  // Timer state
  int _timeRemaining = 30; // 30 seconds per question
  bool _isTimerActive = false;
  
  // Current quiz context
  LevelModel? _currentLevel;
  
  // Getters
  List<QuestionModel> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuestionModel? get currentQuestion => 
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length 
          ? _questions[_currentQuestionIndex] 
          : null;
  Map<int, String> get userAnswers => _userAnswers;
  int get score => _score;
  int get correctAnswers => _correctAnswers;
  bool get isQuizCompleted => _isQuizCompleted;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get timeRemaining => _timeRemaining;
  bool get isTimerActive => _isTimerActive;
  LevelModel? get currentLevel => _currentLevel;
  int get totalQuestions => _questions.length;
  double get progress => _questions.isEmpty ? 0.0 : (_currentQuestionIndex + 1) / _questions.length;
  
  // Initialize quiz with questions from a level
  Future<void> initializeQuiz(LevelModel level, List<QuestionModel> questions) async {
    _currentLevel = level;
    _questions = questions;
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _score = 0;
    _correctAnswers = 0;
    _isQuizCompleted = false;
    _timeRemaining = 30;
    _isTimerActive = true;
    _clearError();
    notifyListeners();
  }
  
  // Answer current question
  void answerQuestion(String answer) {
    if (_currentQuestionIndex < _questions.length) {
      _userAnswers[_currentQuestionIndex] = answer;
      
      // Check if answer is correct
      final currentQ = _questions[_currentQuestionIndex];
      if (answer == currentQ.correctAnswer) {
        _correctAnswers++;
        _score += currentQ.points;
      }
      
      notifyListeners();
    }
  }
  
  // Move to next question
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _timeRemaining = 30; // Reset timer for next question
      notifyListeners();
    } else {
      _completeQuiz();
    }
  }
  
  // Move to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _timeRemaining = 30; // Reset timer
      notifyListeners();
    }
  }
  
  // Skip current question
  void skipQuestion() {
    nextQuestion();
  }
  
  // Complete the quiz
  void _completeQuiz() {
    _isQuizCompleted = true;
    _isTimerActive = false;
    notifyListeners();
  }
  
  // Submit quiz and update user score
  Future<void> submitQuiz(AuthProvider authProvider) async {
    if (!_isQuizCompleted) {
      _completeQuiz();
    }
    
    _setLoading(true);
    
    try {
      // Update user score on backend
      if (authProvider.user != null) {
        await authProvider.updateScore(_score);
      }
      
      // You can add more logic here like saving quiz results
      
    } catch (e) {
      _setError('Failed to submit quiz: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Timer methods
  void decrementTimer() {
    if (_timeRemaining > 0 && _isTimerActive) {
      _timeRemaining--;
      notifyListeners();
      
      if (_timeRemaining == 0) {
        // Time's up, move to next question
        nextQuestion();
      }
    }
  }
  
  void pauseTimer() {
    _isTimerActive = false;
    notifyListeners();
  }
  
  void resumeTimer() {
    _isTimerActive = true;
    notifyListeners();
  }
  
  void resetTimer() {
    _timeRemaining = 30;
    notifyListeners();
  }
  
  // Get quiz results
  Map<String, dynamic> getQuizResults() {
    final percentage = _questions.isEmpty ? 0.0 : (_correctAnswers / _questions.length) * 100;
    
    String grade = 'F';
    if (percentage >= 90) grade = 'A+';
    else if (percentage >= 80) grade = 'A';
    else if (percentage >= 70) grade = 'B';
    else if (percentage >= 60) grade = 'C';
    else if (percentage >= 50) grade = 'D';
    
    return {
      'totalQuestions': _questions.length,
      'correctAnswers': _correctAnswers,
      'wrongAnswers': _questions.length - _correctAnswers,
      'score': _score,
      'percentage': percentage,
      'grade': grade,
      'level': _currentLevel?.title ?? '',
      'difficulty': _currentLevel?.difficulty ?? '',
    };
  }
  
  // Get detailed question results
  List<Map<String, dynamic>> getQuestionResults() {
    List<Map<String, dynamic>> results = [];
    
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final userAnswer = _userAnswers[i];
      final isCorrect = userAnswer == question.correctAnswer;
      
      results.add({
        'question': question.questionText,
        'options': question.options,
        'userAnswer': userAnswer,
        'correctAnswer': question.correctAnswer,
        'correctAnswerText': question.correctOptionText,
        'isCorrect': isCorrect,
        'explanation': question.explanation,
        'points': isCorrect ? question.points : 0,
      });
    }
    
    return results;
  }
  
  // Reset quiz
  void resetQuiz() {
    _questions.clear();
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _score = 0;
    _correctAnswers = 0;
    _isQuizCompleted = false;
    _timeRemaining = 30;
    _isTimerActive = false;
    _currentLevel = null;
    _clearError();
    notifyListeners();
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
  
  // Check if user has answered current question
  bool get hasAnsweredCurrentQuestion => 
      _userAnswers.containsKey(_currentQuestionIndex);
  
  // Get current question user answer
  String? get currentQuestionAnswer => 
      _userAnswers[_currentQuestionIndex];
}
