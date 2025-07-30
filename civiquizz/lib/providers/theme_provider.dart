import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../models/theme_model.dart';
import '../models/level_model.dart';
import '../models/question_model.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  
  List<ThemeModel> _themes = [];
  ThemeModel? _currentTheme;
  List<LevelModel> _currentLevels = [];
  LevelModel? _currentLevel;
  List<QuestionModel> _currentQuestions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ThemeModel> get themes => _themes;
  ThemeModel? get currentTheme => _currentTheme;
  List<LevelModel> get currentLevels => _currentLevels;
  LevelModel? get currentLevel => _currentLevel;
  List<QuestionModel> get currentQuestions => _currentQuestions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all themes
  Future<void> loadThemes() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _themeService.getAllThemes();
      
      if (result['success']) {
        _themes = (result['data'] as List)
            .map((themeData) => ThemeModel.fromJson(themeData))
            .toList();
        notifyListeners();
      } else {
        _setError(result['message']);
      }
    } catch (e) {
      _setError('Failed to load themes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load theme by ID with levels
  Future<void> loadThemeById(String themeId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _themeService.getThemeById(themeId);
      
      if (result['success']) {
        _currentTheme = ThemeModel.fromJson(result['data']);
        notifyListeners();
      } else {
        _setError(result['message']);
      }
    } catch (e) {
      _setError('Failed to load theme: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load levels for a theme
  Future<void> loadThemeLevels(String themeId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _themeService.getThemeLevels(themeId);
      
      if (result['success']) {
        _currentLevels = (result['data'] as List)
            .map((levelData) => LevelModel.fromJson(levelData))
            .toList();
        notifyListeners();
      } else {
        _setError(result['message']);
      }
    } catch (e) {
      _setError('Failed to load theme levels: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load level by ID with questions
  Future<void> loadLevelById(String levelId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _themeService.getLevelById(levelId);
      
      if (result['success']) {
        _currentLevel = LevelModel.fromJson(result['data']);
        if (_currentLevel?.questions != null) {
          _currentQuestions = _currentLevel!.questions!;
        }
        notifyListeners();
      } else {
        _setError(result['message']);
      }
    } catch (e) {
      _setError('Failed to load level: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load questions for a level
  Future<void> loadLevelQuestions(String levelId) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('Loading questions for level: $levelId');
      final result = await _themeService.getLevelQuestions(levelId);
      
      debugPrint('API result: $result');
      
      if (result['success'] == true) {
        final questionsData = result['data'] as List;
        debugPrint('Questions data count: ${questionsData.length}');
        
        _currentQuestions = questionsData
            .map((questionData) {
              try {
                return QuestionModel.fromJson(questionData as Map<String, dynamic>);
              } catch (e) {
                debugPrint('Error parsing question: $e');
                debugPrint('Question data: $questionData');
                rethrow;
              }
            })
            .toList();
        
        debugPrint('Successfully parsed ${_currentQuestions.length} questions');
        notifyListeners();
      } else {
        final errorMessage = result['message'] ?? 'Unknown error';
        debugPrint('API error: $errorMessage');
        _setError(errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('Exception in loadLevelQuestions: $e');
      debugPrint('Stack trace: $stackTrace');
      _setError('Failed to load level questions: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Check answer for a question
  Future<Map<String, dynamic>> checkAnswer(String questionId, String selectedAnswer) async {
    try {
      final result = await _themeService.checkAnswer(questionId, selectedAnswer);
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to check answer: $e'
      };
    }
  }

  // Seed sample data (for development)
  Future<void> seedSampleData() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _themeService.seedData();
      
      if (result['success']) {
        // Reload themes after seeding
        await loadThemes();
      } else {
        _setError(result['message']);
      }
    } catch (e) {
      _setError('Failed to seed data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get theme by ID from loaded themes
  ThemeModel? getThemeById(String themeId) {
    try {
      return _themes.firstWhere((theme) => theme.id == themeId);
    } catch (e) {
      return null;
    }
  }

  // Get level by ID from current levels
  LevelModel? getLevelById(String levelId) {
    try {
      return _currentLevels.firstWhere((level) => level.id == levelId);
    } catch (e) {
      return null;
    }
  }

  // Clear current theme data
  void clearCurrentTheme() {
    _currentTheme = null;
    _currentLevels = [];
    _currentLevel = null;
    notifyListeners();
  }

  // Clear current level data
  void clearCurrentLevel() {
    _currentLevel = null;
    notifyListeners();
  }

  // Private helper methods
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

  // Reset all data
  void reset() {
    _themes = [];
    _currentTheme = null;
    _currentLevels = [];
    _currentLevel = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
