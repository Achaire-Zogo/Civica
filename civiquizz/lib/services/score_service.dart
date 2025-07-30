import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/url.dart';
import 'auth_service.dart';

class ScoreService {
  final AuthService _authService = AuthService();

  /// Update user score and level
  Future<Map<String, dynamic>> updateScore({
    required String userId,
    required int pointsEarned,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${Url.updateScore}$userId?points_earned=$pointsEarned'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Score updated successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update score',
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

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${Url.getUserStats}$userId'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Stats retrieved successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get stats',
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

  /// Calculate points based on quiz performance
  int calculateQuizPoints({
    required int correctAnswers,
    required int totalQuestions,
    required int timeBonus,
    required int difficultyMultiplier,
  }) {
    // Base points per correct answer
    int basePoints = correctAnswers * 10;
    
    // Accuracy bonus (extra points for high accuracy)
    double accuracy = correctAnswers / totalQuestions;
    int accuracyBonus = 0;
    if (accuracy >= 0.9) {
      accuracyBonus = 50; // Perfect or near-perfect
    } else if (accuracy >= 0.8) {
      accuracyBonus = 30; // Very good
    } else if (accuracy >= 0.7) {
      accuracyBonus = 15; // Good
    }
    
    // Time bonus (faster completion = more points)
    int timeBonusPoints = timeBonus.clamp(0, 100);
    
    // Apply difficulty multiplier
    int totalPoints = (basePoints + accuracyBonus + timeBonusPoints) * difficultyMultiplier;
    
    return totalPoints;
  }

  /// Get level requirements (points needed for each level)
  Map<int, int> getLevelRequirements() {
    return {
      1: 0,      // Level 1: 0-99 points
      2: 100,    // Level 2: 100-299 points
      3: 300,    // Level 3: 300-599 points
      4: 600,    // Level 4: 600-999 points
      5: 1000,   // Level 5: 1000-1499 points
      6: 1500,   // Level 6: 1500-2099 points
      7: 2100,   // Level 7: 2100-2799 points
      8: 2800,   // Level 8: 2800-3599 points
      9: 3600,   // Level 9: 3600-4499 points
      10: 4500,  // Level 10: 4500+ points
    };
  }

  /// Calculate level from score
  int calculateLevel(int score) {
    final requirements = getLevelRequirements();
    int level = 1;
    
    for (int i = 10; i >= 1; i--) {
      if (score >= requirements[i]!) {
        level = i;
        break;
      }
    }
    
    return level;
  }

  /// Get points needed for next level
  int getPointsForNextLevel(int currentScore) {
    final currentLevel = calculateLevel(currentScore);
    final requirements = getLevelRequirements();
    
    if (currentLevel >= 10) {
      return 0; // Max level reached
    }
    
    final nextLevelRequirement = requirements[currentLevel + 1]!;
    return nextLevelRequirement - currentScore;
  }
}
