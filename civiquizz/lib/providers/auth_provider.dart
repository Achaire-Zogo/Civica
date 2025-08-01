import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/score_service.dart';
import '../services/life_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ScoreService _scoreService = ScoreService();
  final LifeService _lifeService = LifeService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() async {
    // Check if user is already logged in
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      _token = await _authService.getToken();
      final userData = await _authService.getUserData();
      if (userData != null) {
        _user = UserModel.fromJson(userData);
      }
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String pseudo,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        pseudo: pseudo,
      );

      _setLoading(false);

      if (result['success']) {
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _setError('Network error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );
      print(result);

      _setLoading(false);

      if (result['success']) {
        _token = result['token'];
        // Create user model from response data if available
        if (result['data'] != null) {
          _user = UserModel(
            uid: result['data']['id']?.toString() ?? '',
            email: result['data']['email'] ?? email,
            pseudo: result['data']['spseudo'] ?? '',
            score: result['data']['point'] ?? 0,
            niveau: result['data']['niveaux'] ?? 1,
            badges: ['Débutant'],
            vies: 3,
            lastLifeRefresh: DateTime.now(),
          );
        }
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _setError('Network error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _token = null;
      _setLoading(false);
    } catch (e) {
      _setError('Logout error occurred');
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // For now, we'll just return false as the backend doesn't have this endpoint
      // You can implement this later if needed
      _setLoading(false);
      _errorMessage = 'Password reset not implemented yet';
      return false;
    } catch (e) {
      _setError('Password reset error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.changePassword(
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      _setLoading(false);

      if (result['success']) {
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _setError('Password change error occurred');
      _setLoading(false);
      return false;
    }
  }

  // Helper methods for user data updates (simplified for now)
  Future<void> updateScore(int newScore) async {
    if (_user != null) {
      _user = _user!.copyWith(score: newScore);
      notifyListeners();
    }
  }

  Future<void> updateLevel(int newLevel) async {
    if (_user != null) {
      _user = _user!.copyWith(niveau: newLevel);
      notifyListeners();
    }
  }

  Future<void> addBadge(String badge) async {
    if (_user != null && !_user!.badges.contains(badge)) {
      List<String> newBadges = List.from(_user!.badges)..add(badge);
      _user = _user!.copyWith(badges: newBadges);
      notifyListeners();
    }
  }

  Future<void> updateLives(int newLives) async {
    if (_user != null) {
      _user = _user!.copyWith(vies: newLives, lastLifeRefresh: DateTime.now());
      notifyListeners();
    }
  }

  // Check and refresh lives based on time
  Future<void> checkAndRefreshLives() async {
    if (_user != null) {
      final now = DateTime.now();
      final lastRefresh = _user!.lastLifeRefresh ?? now;
      final timeDiff = now.difference(lastRefresh);

      // Refresh one life every 30 minutes, max 3 lives
      if (timeDiff.inMinutes >= 30 && _user!.vies < 3) {
        final livesToAdd = (timeDiff.inMinutes ~/ 30).clamp(0, 3 - _user!.vies);
        _user = _user!.copyWith(
          vies: (_user!.vies + livesToAdd).clamp(0, 3),
          lastLifeRefresh: now,
        );
        notifyListeners();
      }
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Update user score
  Future<bool> updateUserScore(int pointsEarned) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final result = await _scoreService.updateScore(
        userId: _user!.uid,
        pointsEarned: pointsEarned,
      );

      if (result['success']) {
        // Update local user data
        final data = result['data'];
        _user = _user!.copyWith(
          score: data['new_score'],
          niveau: data['new_level'],
        );

        // Update stored user data
        await _authService.storeUserData(_user!.toJson());

        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erreur lors de la mise à jour du score');
      _setLoading(false);
      return false;
    }
  }

  // Refresh user stats from server
  Future<bool> refreshUserStats() async {
    if (_user == null) return false;

    try {
      final result = await _scoreService.getUserStats(_user!.uid);

      if (result['success']) {
        final data = result['data'];
        _user = _user!.copyWith(
          score: data['score'],
          niveau: data['level'],
        );

        // Update stored user data
        await _authService.storeUserData(_user!.toJson());

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Use a life for quiz gameplay
  Future<bool> useLife() async {
    if (_user == null || _user!.vies <= 0) return false;

    _setLoading(true);
    _clearError();

    try {
      final result = await _lifeService.useLife(_user!.uid);

      if (result['success']) {
        // Update local user data
        final data = result['data'];
        _user = _user!.copyWith(
          vies: data['remaining_lives'],
        );

        // Update stored user data
        await _authService.storeUserData(_user!.toJson());

        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erreur lors de l\'utilisation d\'une vie');
      _setLoading(false);
      return false;
    }
  }

  // Refresh lives from server
  Future<bool> refreshLives() async {
    if (_user == null) return false;

    try {
      final result = await _lifeService.refreshLives(_user!.uid);

      if (result['success']) {
        final data = result['data'];
        _user = _user!.copyWith(
          vies: data['current_lives'],
          lastLifeRefresh: DateTime.now(),
        );

        // Update stored user data
        await _authService.storeUserData(_user!.toJson());

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get life status from server
  Future<Map<String, dynamic>?> getLifeStatus() async {
    if (_user == null) return null;

    try {
      final result = await _lifeService.getLifeStatus(_user!.uid);

      if (result['success']) {
        final data = result['data'];
        _user = _user!.copyWith(
          vies: data['current_lives'],
        );

        // Update stored user data
        await _authService.storeUserData(_user!.toJson());

        notifyListeners();
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user can play (has lives)
  bool canPlay() {
    return _user != null && _user!.vies > 0;
  }

  // Get time until next life
  Duration getTimeUntilNextLife() {
    if (_user == null || _user!.vies >= 3) {
      return Duration.zero;
    }
    return _lifeService.getTimeUntilNextLife(
      _user!.lastLifeRefresh ?? DateTime.now(),
      _user!.vies,
    );
  }

  // Format time until next life for display
  String formatTimeUntilNextLife() {
    return _lifeService.formatTimeUntilNextLife(getTimeUntilNextLife());
  }

  // Get life message for UI
  String getLifeMessage() {
    if (_user == null) return "Statut des vies inconnu";
    return _lifeService.getLifeMessage(_user!.vies);
  }
}
