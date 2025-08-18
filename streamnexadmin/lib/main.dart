import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:streamnexadmin/presentation/bottom_navigation_screen/view/bottom_navigation_screen.dart';
import 'package:streamnexadmin/presentation/spalsh_screen/view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

