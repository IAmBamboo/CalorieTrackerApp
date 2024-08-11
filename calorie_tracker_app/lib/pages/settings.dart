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
                _showCalorieLimitPopup(context);
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  /// Builds a pop up window that allows the user to set their daily calorie limit
  /// It will pass through the user input to the appstate to update onto the server
  /// their new calorie limit.
  /// Arguments:
  /// - context: The BuildContext to be passed
  Future<void> _showCalorieLimitPopup(BuildContext context) async {
    final TextEditingController calorieLimitController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 31, 31, 31),
          title: const Text(
            'Update Calorie Limit',
            maxLines: 3,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: Color.fromARGB(255, 255, 242, 199),
              fontSize: 20,
              shadows: <Shadow>[
                Shadow(
                  blurRadius: 2,
                  color: Color.fromARGB(255, 255, 228, 141),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your current daily calorie limit is: ${appState.userSettings!.caloriesLimit.toString()}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: calorieLimitController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 190, 190, 190),
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter new limit',
                                      hintStyle: TextStyle(
                                        color: Color.fromARGB(255, 190, 190, 190),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ),
                            const SizedBox(width: 8),
                            const Text('cal/day',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                int? userEnteredAmount = int.tryParse(calorieLimitController.text);
                if (userEnteredAmount != null) {
                  final currentUserSettings = appState.userSettings;
                  if (currentUserSettings != null) {
                    currentUserSettings.caloriesLimit = userEnteredAmount;
                    appState.updateUserSettings(userSettings: currentUserSettings);
                    Navigator.of(context).pop();
                  } else {
                    print('Console Print: userSettings is null, cannot update.');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}