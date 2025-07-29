import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/url.dart';

class ThemeService {
  // Get authentication token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all themes
  Future<Map<String, dynamic>> getAllThemes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(Url.themes),
        headers: headers,
      );

      log('Get themes response: ${response.statusCode}');
      log('Get themes body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
          'message': data['message'] ?? 'Themes retrieved successfully'
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to get themes'
        };
      }
    } catch (e) {
      log('Error getting themes: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to connect to server'
      };
    }
  }

  // Get theme by ID with levels
  Future<Map<String, dynamic>> getThemeById(String themeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Url.getThemeById}$themeId'),
        headers: headers,
      );

      log('Get theme by ID response: ${response.statusCode}');
      log('Get theme by ID body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Theme retrieved successfully'
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to get theme'
        };
      }
    } catch (e) {
      log('Error getting theme by ID: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to connect to server'
      };
    }
  }

  // Get theme levels
  Future<Map<String, dynamic>> getThemeLevels(String themeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Url.getThemeLevels}$themeId/levels'),
        headers: headers,
      );

      log('Get theme levels response: ${response.statusCode}');
      log('Get theme levels body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
          'message': data['message'] ?? 'Theme levels retrieved successfully'
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to get theme levels'
        };
      }
    } catch (e) {
      log('Error getting theme levels: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to connect to server'
      };
    }
  }

  // Get level by ID with questions (for quiz)
  Future<Map<String, dynamic>> getLevelById(String levelId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Url.getLevelById}$levelId'),
        headers: headers,
      );

      log('Get level by ID response: ${response.statusCode}');
      log('Get level by ID body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Level retrieved successfully'
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to get level'
        };
      }
    } catch (e) {
      log('Error getting level by ID: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to connect to server'
      };
    }
  }

  // Check answer for a question
  Future<Map<String, dynamic>> checkAnswer(
      String questionId, String selectedAnswer) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${Url.checkAnswer}$questionId/check-answer'),
        headers: headers,
        body: json.encode({
          'selected_answer': selectedAnswer,
        }),
      );

      log('Check answer response: ${response.statusCode}');
      log('Check answer body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Answer checked successfully'
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to check answer'
        };
      }
    } catch (e) {
      log('Error checking answer: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to connect to server'
      };
    }
  }

  // Seed sample data (for development/testing)
  Future<Map<String, dynamic>> seedData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(Url.seedData),
        headers: headers,
      );

      log('Seed data response: ${response.statusCode}');
      log('Seed data body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Sample data seeded successfully'
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to seed data'
        };
      }
    } catch (e) {
      log('Error seeding data: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to connect to server'
      };
    }
  }
}
