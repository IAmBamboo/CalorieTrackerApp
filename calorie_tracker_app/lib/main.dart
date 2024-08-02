import 'package:flutter/material.dart';
import 'package:calorie_tracker_app/widgets/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp()); // Start with MyApp
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      home: SplashScreen(), // Start with SplashScreen
    );
  }
}