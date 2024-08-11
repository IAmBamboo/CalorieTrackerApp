import 'package:calorie_tracker_app/models/user_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calorie_tracker_app/app_state.dart';
import 'package:calorie_tracker_app/models/log.dart';
import 'package:calorie_tracker_app/pages/day_log_view.dart';
import 'package:calorie_tracker_app/widgets/calorie_header.dart';

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
  group('DayLogView Tests', () {
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

    testWidgets('renders DayLogView with logs and the floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DayLogView(
            appState: appState,
            logsList: appState.logs ?? [],
            expandedTile: null,
            onTileTap: (index) {},
            onLogAction: (index, action) {},
          ),
        ),
      );

      expect(find.text('Daily Log - August 11, 2024'), findsOneWidget);
      expect(find.byType(CalorieHeader), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows "No logs available." when logsList is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DayLogView(
            appState: appState,
            logsList: [],
            expandedTile: null,
            onTileTap: (index) {},
            onLogAction: (index, action) {},
          ),
        ),
      );

      expect(find.text('No logs available.'), findsOneWidget);
    });

    testWidgets('Appstate date changes when using date picker', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DayLogView(
            appState: appState,
            logsList: appState.logs ?? [],
            expandedTile: null,
            onTileTap: (index) {},
            onLogAction: (index, action) {},
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.calendar_today_rounded));
      await tester.pump();

      expect(find.byType(DatePickerDialog), findsOneWidget);

      await tester.tap(find.text('15').last); // Select the 15th
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK').last); // Hit OK
      await tester.pumpAndSettle();

      expect(appState.date, DateTime(2024, 8, 15));
    });
  });
}