import 'package:bs_app_mobile/iu/pages/intro.dart';
import 'package:bs_app_mobile/services/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Cette méthode est le point d'entrée de votre application.
  @override
  Widget build(BuildContext context) {
    // Initialiser Firebase ici pour avoir accès au BuildContext
    FirebaseMessage.initializeFirebase(context); 

    return MaterialApp(
      color: const Color(0xFFFFFFFF),
      title: "Banque de sang",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFD80032),
        hintColor: const Color(0xFFF5F5F5),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      home: const IntroPage(),
    );
  }
}
