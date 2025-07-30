import '../models/question_model.dart';
import '../models/theme_model.dart';
import '../models/level_model.dart';

class SampleData {
  // Questions d'exemple sur la Constitution française
  static List<QuestionModel> getSampleQuestions() {
    return [];
  }

  // Thèmes d'exemple
  static List<ThemeModel> getSampleThemes() {
    return [];
  }

  // Niveaux d'exemple
  static List<LevelModel> getSampleLevels() {
    return [];
  }

  // Méthode pour initialiser les données d'exemple dans Firebase
  static Map<String, dynamic> getFirebaseData() {
    final questions = getSampleQuestions();
    final themes = getSampleThemes();
    final levels = getSampleLevels();

    Map<String, dynamic> questionsMap = {};
    for (var question in questions) {
      questionsMap[question.id] = question.toJson();
    }

    Map<String, dynamic> themesMap = {};
    for (var theme in themes) {
      themesMap[theme.id] = theme.toJson();
    }

    Map<String, dynamic> levelsMap = {};
    for (var level in levels) {
      levelsMap[level.id] = level.toJson();
    }

    return {
      'questions': questionsMap,
      'themes': themesMap,
      'levels': levelsMap,
    };
  }
}
