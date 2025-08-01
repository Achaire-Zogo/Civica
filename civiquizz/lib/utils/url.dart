class Url {
  static const String baseUrl = 'http://192.168.185.19:5002';

  // Authentication endpoints
  static const String login = "$baseUrl/api/user/login";
  static const String register = "$baseUrl/api/user/register";
  static const String checkEmail = "$baseUrl/api/user/check-email";
  static const String changePassword = "$baseUrl/api/user/change-password";

  // User endpoints
  static const String getAllUsers = "$baseUrl/api/user/";
  static const String getUserById = "$baseUrl/api/user/";
  static const String updateUser = "$baseUrl/api/user/";
  static const String deleteUser = "$baseUrl/api/user/";
  static const String updateScore = "$baseUrl/api/user/update-score/";
  static const String getUserStats = "$baseUrl/api/user/stats/";
  static const String useLife = "$baseUrl/api/user/use-life/";
  static const String refreshLives = "$baseUrl/api/user/refresh-lives/";
  static const String getLifeStatus = "$baseUrl/api/user/life-status/";

  // Theme endpoints
  static const String themes = "$baseUrl/api/theme";
  static const String getThemeById = "$baseUrl/api/theme/";
  static const String getThemeLevels = "$baseUrl/api/theme/";
  static const String getLevelById = "$baseUrl/api/level/";
  static const String getLevelQuestions = "$baseUrl/api/level/";
  static const String checkAnswer = "$baseUrl/api/question/";
  static const String seedData = "$baseUrl/api/theme/seed-data";

  // Quiz endpoints (to be added later if needed)
  static const String quizzes = "$baseUrl/api/quiz/";

  // Other endpoints can be added here as needed
}
