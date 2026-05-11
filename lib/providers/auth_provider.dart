import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = true;

  User? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    try {

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;

    } on FirebaseAuthException catch (e) {
      print(e.code);

      switch (e.code) {

        case 'invalid-credential':
          return 'Email or password is incorrect';

        case 'network-request-failed':
          return 'No internet connection';

        default:
          return 'Login failed';
      }
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;

    } on FirebaseAuthException catch (e) {

      switch (e.code) {

        case 'email-already-in-use':
          return 'Email already in use';

        case 'weak-password':
          return 'Password is too weak';

        case 'invalid-email':
          return 'Invalid email address';

        default:
          return 'Registration failed';
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
      _user = null;
      notifyListeners();
    }
  }
  Future<String?> resetPassword(String email) async {
    try {

      await _auth.sendPasswordResetEmail(email: email);

      return null;

    } on FirebaseAuthException catch (e) {

      switch (e.code) {

        case 'user-not-found':
          return 'No user found with this email';

        case 'invalid-email':
          return 'Invalid email address';

        default:
          return e.message ?? 'Password reset failed';
      }
    }
  }
}

