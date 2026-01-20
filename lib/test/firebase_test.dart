// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> testFirebase() async {
  // firebase auth test
  try {
    final userCredentials = await FirebaseAuth.instance.signInAnonymously();
    print('user: ${userCredentials.user?.uid}');
  } catch (e) {
    print('authorization error: $e');
  }

  // firebase firestore test
  try {
    final db = FirebaseFirestore.instance;
    await db.collection('test').add({
      'name': 'test',
      'timestamp': DateTime.now(),
    });
    print('firestore: success');
  } catch (e) {
    print('firestore error: $e');
  }

  // firebase storage test
  try {
    final storage = FirebaseStorage.instance;
    await storage.ref('test/test.txt').putString('${DateTime.now()}');
    print("firebase storage: success");
  } catch (e) {
    print('firebase storage error: $e');
  }
}
