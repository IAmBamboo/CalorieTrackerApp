import 'package:calorie_tracker_app/app_state.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final AppState appState;
  const SettingsPage({
    required this.appState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
        title: const Text("Settings",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 228, 141),
            shadows: <Shadow>[
              Shadow(
                blurRadius: 2,
                color: Color.fromARGB(255, 255, 228, 141),
              ),
            ]
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle,
              color: Color.fromARGB(255, 255, 228, 141),
              shadows: <Shadow>[
                Shadow(
                  blurRadius: 5,
                  color: Color.fromARGB(255, 255, 228, 141),
                ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          '${appState.userSettings?.caloriesLimit}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}