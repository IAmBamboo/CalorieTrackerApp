import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:assignment_02_notes_app/app_state.dart';
import 'package:assignment_02_notes_app/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create our AppState
  AppState appState = AppState();

  runApp(MainApp(
    appState: appState,
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final routes = {
      '/': (context) {
        return HomePage(appState: appState); //Default page is the Notes Overview Page
      },
      '/sign-in': (context) {
        return SignInScreen(
          actions: [
            AuthStateChangeAction((context, state) {
              // state has changed, find out what happened and deal with it
              final user = switch (state) {
                SignedIn state => state.user,
                UserCreated state => state.credential.user,
                _ => null,
              };

              if (user == null) {
                return; //Do nothing
              }

              if (state is UserCreated) {
                // New user, update their display name
                user.updateDisplayName(user.email!.split('@').first);
              }

              // remove the modal
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            }),
          ],
        );
      },
      '/profile': (context) {
        return ProfileScreen(
          actions: [
            SignedOutAction((context) {
              // Remove the modal
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            }),
          ],
        );
      },
    };

    return MaterialApp(
      title: 'Notes App',
      routes: routes,
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => HomePage(
              appState: appState,
            )
          );
        }
        // For any other route, use the default behaviour
        return null;
      },
    );
  }
}