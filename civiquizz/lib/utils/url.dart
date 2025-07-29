class Url {
  static const String baseUrl = 'http://192.168.1.143:5002';

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
  
  // Quiz endpoints (to be added later if needed)
  static const String quizzes = "$baseUrl/api/quiz/";
  
  // Other endpoints can be added here as needed
}
