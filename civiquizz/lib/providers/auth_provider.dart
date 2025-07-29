import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _authService.getUserData(firebaseUser.uid);
        if (_user != null) {
          _user = await _authService.checkAndRefreshLives(_user!);
        }
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String pseudo,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        pseudo: pseudo,
      );
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _setError(_getErrorMessage(e));
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
      _user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (_user != null) {
        _user = await _authService.checkAndRefreshLives(_user!);
      }
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    _setLoading(false);
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateUserData(UserModel updatedUser) async {
    try {
      await _authService.updateUserData(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }

  void updateScore(int points) {
    if (_user != null) {
      _user = _user!.copyWith(score: _user!.score + points);
      _authService.updateUserData(_user!);
      notifyListeners();
    }
  }

  void useLife() {
    if (_user != null && _user!.vies > 0) {
      _user = _user!.copyWith(vies: _user!.vies - 1);
      _authService.updateUserData(_user!);
      notifyListeners();
    }
  }

  void addBadge(String badge) {
    if (_user != null && !_user!.badges.contains(badge)) {
      List<String> newBadges = List.from(_user!.badges)..add(badge);
      _user = _user!.copyWith(badges: newBadges);
      _authService.updateUserData(_user!);
      notifyListeners();
    }
  }

  void levelUp() {
    if (_user != null) {
      _user = _user!.copyWith(niveau: _user!.niveau + 1);
      _authService.updateUserData(_user!);
      notifyListeners();
    }
  }

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
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé.';
        case 'weak-password':
          return 'Le mot de passe est trop faible.';
        case 'invalid-email':
          return 'Email invalide.';
        default:
          return 'Une erreur est survenue: ${error.message}';
      }
    }
    return 'Une erreur inattendue est survenue.';
  }
}
