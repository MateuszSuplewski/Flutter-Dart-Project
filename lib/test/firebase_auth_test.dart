// ignore_for_file: avoid_print

import '../data/firebase_auth_repository.dart';

Future<void> authTest() async {
  final authRepository = FirebaseAuthRepository();

  //register test
  String email = "test1@test.com", password = "weak1234";
  try{
    await authRepository.register(email: email, password: password);
    print('auth register ended with success');
  } catch(e) {
    print("auth register ended with failure: $e");
  }

  //login test
  try{
    await authRepository.signIn(email: email, password: password);
    print('auth login ended with success, current user: ${authRepository.getCurrentUser()?.uid}');
  } catch(e) {
    print("auth login process ended with failure: $e");
  }

  //sign off test
  try{
    await authRepository.signOut();
    print("auth sign out ended with success");
  } catch(e){
    print("auth sign out failed: $e");
  }

  //sign in anonymously
  try{
    await authRepository.signInAnonymously();
    print('anon login ended with success, current user: ${authRepository.getCurrentUser()?.uid}');
  } catch(e){
    print("anon login ended with failure: $e");
  }

}