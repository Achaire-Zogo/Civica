import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  
  List<Map<String, dynamic>> _themes = [];
  Map<String, dynamic>? _currentTheme;
  List<Map<String, dynamic>> _currentLevels = [];
  Map<String, dynamic>? _currentLevel;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get themes => _themes;
  Map<String, dynamic>? get currentTheme => _currentTheme;
  List<Map<String, dynamic>> get currentLevels => _currentLevels;
  Map<String, dynamic>? get currentLevel => _currentLevel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all themes
  Future<void> loadThemes() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _themeService.getAllThemes();
      
      if (result['success']) {
        _themes = List<Map<String, dynamic>>.from(result['data']);
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
        _currentTheme = result['data'];
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
        _currentLevels = List<Map<String, dynamic>>.from(result['data']);
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
        _currentLevel = result['data'];
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
  Map<String, dynamic>? getThemeById(String themeId) {
    try {
      return _themes.firstWhere((theme) => theme['id'] == themeId);
    } catch (e) {
      return null;
    }
  }

  // Get level by ID from current levels
  Map<String, dynamic>? getLevelById(String levelId) {
    try {
      return _currentLevels.firstWhere((level) => level['id'] == levelId);
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
