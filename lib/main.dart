import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_project_app/firebase_options.dart';
import 'package:provider/provider.dart';
import 'data/firebase_auth_repository.dart';
import 'core/auth_provider.dart';
import 'presentation/home_screen.dart';
import 'presentation/auth/login_screen.dart';
// import 'test/firebase_auth_test.dart'; // to be deleted
// import 'test/firebase_test.dart'; //to be deleted

//terminal -> flutter run
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authRepository = FirebaseAuthRepository();

  //just for testing
  // await testFirebase();
  // await authTest();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(authRepository: authRepository),
      child: const MyApp(), 
    )
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter-Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Consumer<AuthProvider>(builder: (context, authProvider, _){
        if(authProvider.currentUser != null){
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },)
    );
  }
}
