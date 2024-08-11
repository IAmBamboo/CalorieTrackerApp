import 'package:calorie_tracker_app/pages/main_app.dart';
import 'package:flutter/material.dart';
import 'package:calorie_tracker_app/app_state.dart';

//This is a splash screen used to render something so the app doesn't glitch out
//before the appstate is able to initialize and provide a user status
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<void> _initFuture;
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _initFuture = _appState.init(); // Initialize AppState
    _initFuture.then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainApp(appState: _appState),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(), // Show loading indicator
      ),
    );
  }
}