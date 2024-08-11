import 'package:calorie_tracker_app/models/log.dart';
import 'package:calorie_tracker_app/models/user_settings.dart';
import 'package:calorie_tracker_app/pages/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  late MockAppState appState;
  group('SettingsPage Tests', () {
    setUp(() {
      appState = MockAppState();
      appState._date = DateTime(2024, 8, 11); //set to aug 11 2024
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
    testWidgets('displays SettingsPage and handles Calorie Limit popup', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPage(appState: appState),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Calorie Limit'), findsOneWidget);

      await tester.tap(find.text('Calorie Limit'));
      await tester.pumpAndSettle();

      expect(find.text('Update Calorie Limit'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter new limit'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '2500');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(appState.userSettings?.caloriesLimit, 2500);
    });
  });
}