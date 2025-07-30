import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/url.dart';
import 'auth_service.dart';

class LifeService {
  final AuthService _authService = AuthService();

  /// Use a life for quiz gameplay
  Future<Map<String, dynamic>> useLife(String userId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${Url.useLife}$userId'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Life used successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to use life',
          'error': responseData['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString(),
      };
    }
  }

  /// Refresh user lives based on time elapsed
  Future<Map<String, dynamic>> refreshLives(String userId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${Url.refreshLives}$userId'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Lives refreshed successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to refresh lives',
          'error': responseData['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString(),
      };
    }
  }

  /// Get current life status
  Future<Map<String, dynamic>> getLifeStatus(String userId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${Url.getLifeStatus}$userId'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Life status retrieved successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get life status',
          'error': responseData['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString(),
      };
    }
  }

  /// Calculate time until next life refresh
  Duration getTimeUntilNextLife(DateTime lastLifeRefresh, int currentLives) {
    if (currentLives >= 3) {
      return Duration.zero; // Already at max lives
    }

    const lifeCooldown = Duration(minutes: 30);
    final nextLifeTime = lastLifeRefresh.add(lifeCooldown);
    final now = DateTime.now();

    if (now.isAfter(nextLifeTime)) {
      return Duration.zero; // Life should already be available
    }

    return nextLifeTime.difference(now);
  }

  /// Format time duration for display
  String formatTimeUntilNextLife(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) {
      return "Disponible maintenant";
    }

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  /// Check if user can play (has at least 1 life)
  bool canPlay(int currentLives) {
    return currentLives > 0;
  }

  /// Get life icon based on current lives
  String getLifeIcon(int currentLives, int maxLives) {
    if (currentLives == maxLives) {
      return "❤️"; // Full heart
    } else if (currentLives > 0) {
      return "💛"; // Yellow heart
    } else {
      return "🖤"; // Black heart (empty)
    }
  }

  /// Get encouragement message based on life status
  String getLifeMessage(int currentLives) {
    switch (currentLives) {
      case 3:
        return "Vous avez toutes vos vies ! Prêt à jouer ?";
      case 2:
        return "Il vous reste 2 vies. Continuez !";
      case 1:
        return "Dernière vie ! Jouez prudemment.";
      case 0:
        return "Plus de vies. Attendez le rechargement.";
      default:
        return "Statut des vies inconnu.";
    }
  }
}
