import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fcm_app/fcm_notification.dart';
import 'package:flutter_fcm_app/firebase_options.dart';
import 'package:flutter_fcm_app/shared_prefs.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FcmNotificationService().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  TextEditingController controller = TextEditingController();
  bool saved = false;

  Future<void> addUser() async {
    if (controller.text.isNotEmpty) {
      await users.add({
        'name': controller.text,
        'device_token': SharedPrefs().fcm,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Firebase Enter name to get notification'),
            TextField(
              controller: controller,
            ),
            TextButton(
              onPressed: saved ? null : () => addUser(),
              child: Text(saved ? 'Submitted' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
