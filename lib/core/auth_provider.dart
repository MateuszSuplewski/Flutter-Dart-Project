import 'package:flutter/material.dart';
import '../data/firebase_auth_repository.dart';
import '../domain/auth_failures.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthRepository authRepository;

  AuthProvider({required this.authRepository}) {
    _currentUser = authRepository.getCurrentUser();
  }

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> loginEmail(String email, String password) async {
    _setLoading(true);
    try {
      final user = await authRepository.signIn(email: email, password: password);
      _currentUser = user;
    } on Failure {
      rethrow;
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> loginAnonymous() async {
    _setLoading(true);
    try {
      final user = await authRepository.signInAnonymously();
      _currentUser = user;
    } on Failure {
      rethrow;
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> registerEmail(String email, String password) async {
    _setLoading(true);
    try {
      final user = await authRepository.register(email: email, password: password);
      _currentUser = user;
    } on Failure {
      rethrow;
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
