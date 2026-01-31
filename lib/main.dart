import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_project_app/firebase_options.dart';
import 'package:provider/provider.dart';
import 'data/firebase_auth_repository.dart';
import 'core/auth_provider.dart';
import 'presentation/home_screen.dart';
import 'presentation/auth/login_screen.dart';
import 'domain/repositories/artifact_repository.dart';
import 'data/repositories/firebase_artifact_repository.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // await FirebaseMessaging.instance.subscribeToTopic('all');

  final authRepository = FirebaseAuthRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<ArtifactRepository>(
          create: (_) => FirebaseArtifactRepository(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
      ],
      child: MyApp(state: ApplicationState()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.state});

  final ApplicationState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter-Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          state.subscribeToTopic('all');
          if (authProvider.currentUser != null) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  late FirebaseMessaging firebaseMessaging;

  String _fcmToken = ''; // Needed for web push notifications

  String get fcmToken => _fcmToken;

  bool _messagingAllowed = false;

  bool get messagingAllowed => _messagingAllowed;

Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    firebaseMessaging = FirebaseMessaging.instance;

    firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      debugPrint(token);
      notifyListeners();
    });

const vapidKey = '';
    firebaseMessaging.getToken(vapidKey: vapidKey).then((token) {
      if (token != null) {
        _fcmToken = token;
        debugPrint(token);
        notifyListeners();
      }
    });

firebaseMessaging.getNotificationSettings().then((settings) {
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _messagingAllowed = true;
        notifyListeners();
      }
    });

    FirebaseMessaging.onMessage.listen((remoteMessage) {
      debugPrint('Got a message in the foreground');
      debugPrint('message data: ${remoteMessage.data}');

      if (remoteMessage.notification != null) {
        debugPrint('message is a notification');
      }
    });
  }

Future<void> requestMessagingPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _messagingAllowed = true;
      notifyListeners();
    }

    debugPrint('Users permission status: ${settings.authorizationStatus}');
  }

  Future<void> subscribeToTopic(String topic) async {
    await firebaseMessaging.subscribeToTopic(topic);
  }
}