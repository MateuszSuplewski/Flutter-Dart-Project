import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_failures.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<User> signIn({required String email, required String password}) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = result.user;
      if (user == null) {
        throw UnknownFailure("Błąd logowania");
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw InvalidCredentialsFailure();
      } else if (e.code == 'network-request-failed') {
        throw NetworkFailure();
      } else {
        throw UnknownFailure(e.message ?? "Nieznany błąd");
      }
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<User> signInAnonymously() async {
    try {
      final result = await _firebaseAuth.signInAnonymously();
      final user = result.user;
      if (user == null) {
        throw UnknownFailure("Błąd logowania anonimowego");
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw NetworkFailure();
      } else {
        throw UnknownFailure(e.message ?? "Nieznany błąd");
      }
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
Future<User> register({required String email, required String password}) async {
  try {
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = result.user;
    if (user == null) {
      throw UnknownFailure("Błąd rejestracji");
    }
    await _firestore.collection('users').doc(user.uid).set({
      'role': 'viewer',
      'email': email
    });
    return user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      throw InvalidCredentialsFailure("Email jest już użyty");
    } else if (e.code == 'network-request-failed') {
      throw NetworkFailure();
    } else if (e.code == 'weak-password') {
      throw InvalidCredentialsFailure("Hasło jest zbyt słabe");
    } else {
      throw UnknownFailure(e.message ?? "Nieznany błąd");
    }
  } catch (e) {
    throw UnknownFailure(e.toString());
  }
}


  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
