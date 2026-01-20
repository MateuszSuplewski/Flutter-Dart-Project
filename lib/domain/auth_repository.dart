import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User> signIn({required String email, required String password});
  Future<User> signInAnonymously();
  Future<User> register({required String email, required String password});
  Future<void> signOut();
  User? getCurrentUser();
}