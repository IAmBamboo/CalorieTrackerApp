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
        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //Calorie Limit Section
            ListTile(
              title: const Text(
                'Calorie Limit',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 242, 199),
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 2,
                      color: Color.fromARGB(255, 255, 228, 141),
                    ),
                  ],
                ),
              ),
              subtitle: const Text('Set your daily calorie limit',
                style: TextStyle(
                  color: Color.fromARGB(255, 190, 190, 190),
                ),
              ),
              trailing: const Icon(Icons.restaurant,
                color: Color.fromARGB(255, 255, 228, 141),
                shadows: <Shadow>[
                  Shadow(
                    blurRadius: 5,
                    color: Color.fromARGB(255, 255, 228, 141),
                  ),
                ],
              ),
              onTap: () {
                // Navigate to User settings
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}