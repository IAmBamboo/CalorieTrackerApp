import 'package:calorie_tracker_app/models/user_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calorie_tracker_app/models/log.dart';
import 'package:calorie_tracker_app/pages/home.dart';
import 'package:calorie_tracker_app/app_state.dart';

class MockAppState extends AppState {
  @override
  bool get loggedIn => _loggedIn;
  bool _loggedIn = false;

  @override
  User? get user => _user;
  User? _user;
  @override
  set user(User? user) {
    _user = user;
  }

  @override
  DateTime? get date => _date;
  DateTime? _date;
  set date(DateTime? date) {
    _date = date;
  }

  @override
  List<Log>? get logs => _logs;
  List<Log>? _logs;
  void setLogs(List<Log>? logs) {
    _logs = logs;
  }

  @override
  UserSettings? get userSettings => _userSettings;
  UserSettings? _userSettings;
  void setUserSettings(UserSettings userSettings) {
    _userSettings = userSettings;
  }

  void setLoggedIn(bool loggedIn) {
    _loggedIn = loggedIn;
  }
}

void main() {
  group('HomePage Tests', () {
    late MockAppState appState;

    setUp(() {
      appState = MockAppState();
      appState._date = DateTime.now();
      appState.setUserSettings(
        UserSettings(caloriesLimit: 1800)
      );
      appState.setLoggedIn(true);
      appState.setLogs([
        Log(
          id: 'log1',
          foodId: 'food1',
          calories: 100,
          eatTime: 'Breakfast',
          name: 'Apple',
          servingUnit: 'g',
          servingMeasured: 150.0,
        ),
      ]);
    });

    testWidgets('renders CircularProgressIndicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomePage(appState: appState),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders HomePage with BottomNavigationBar after loading', (WidgetTester tester) async {
      appState.setLoggedIn(true);

      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(appState: appState),
        ),
      );

      appState.notifyListeners();
      await tester.pump();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('shows Sign In button when not logged in', (WidgetTester tester) async {
      appState.setLoggedIn(false);

      await tester.pumpWidget(MaterialApp(
        home: HomePage(appState: appState),
      ));

      // Simulate loading complete
      appState.notifyListeners();
      await tester.pump();

      expect(find.text('Sign In'), findsOneWidget);
    });
  });
}