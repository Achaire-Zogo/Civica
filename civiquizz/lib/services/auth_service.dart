import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream pour écouter les changements d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Inscription avec email et mot de passe
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String pseudo,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Créer le profil utilisateur dans Firestore
        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          pseudo: pseudo,
          score: 0,
          niveau: 1,
          badges: ['Débutant'],
          vies: 3,
          lastLifeRefresh: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());

        return userModel;
      }
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      rethrow;
    }
    return null;
  }

  // Connexion avec email et mot de passe
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        return await getUserData(user.uid);
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      rethrow;
    }
    return null;
  }

  // Récupérer les données utilisateur depuis Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
    }
    return null;
  }

  // Mettre à jour les données utilisateur
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toJson());
    } catch (e) {
      print('Erreur lors de la mise à jour des données utilisateur: $e');
      rethrow;
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erreur lors de la réinitialisation du mot de passe: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  // Vérifier et recharger les vies
  Future<UserModel?> checkAndRefreshLives(UserModel user) async {
    DateTime now = DateTime.now();
    DateTime? lastRefresh = user.lastLifeRefresh;
    
    if (lastRefresh != null) {
      int hoursSinceLastRefresh = now.difference(lastRefresh).inHours;
      int newLives = (user.vies + (hoursSinceLastRefresh ~/ 2)).clamp(0, 3);
      
      if (newLives != user.vies) {
        UserModel updatedUser = user.copyWith(
          vies: newLives,
          lastLifeRefresh: now,
        );
        await updateUserData(updatedUser);
        return updatedUser;
      }
    }
    
    return user;
  }
}
