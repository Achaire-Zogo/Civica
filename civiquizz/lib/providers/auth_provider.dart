import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
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
      
      _setLoading(false);
      
      if (result['success']) {
        _token = result['token'];
        // Create user model from response data if available
        if (result['data'] != null) {
          _user = UserModel(
            uid: result['data']['id']?.toString() ?? '',
            email: result['data']['email'] ?? email,
            pseudo: result['data']['pseudo'] ?? '',
            score: 0,
            niveau: 1,
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

  // Use a life (for quiz gameplay)
  Future<void> useLife() async {
    if (_user != null && _user!.vies > 0) {
      _user = _user!.copyWith(vies: _user!.vies - 1, lastLifeRefresh: DateTime.now());
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
}
