import 'package:calorie_tracker_app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:calorie_tracker_app/widgets/splash.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(), // Initialize AppState here
      child: MyApp(), // Start with MyApp
    ),
  );
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