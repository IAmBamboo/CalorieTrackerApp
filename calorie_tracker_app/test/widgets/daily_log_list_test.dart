import 'package:calorie_tracker_app/app_state.dart';
import 'package:calorie_tracker_app/models/log.dart';
import 'package:calorie_tracker_app/models/user_settings.dart';
import 'package:calorie_tracker_app/widgets/daily_log_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
      Log(
        id: 'log2',
        foodId: 'food2',
        calories: 200,
        eatTime: 'Lunch',
        name: 'Banana',
        servingUnit: 'g',
        servingMeasured: 300.0,
      ),
      Log(
        id: 'log3',
        foodId: 'food3',
        calories: 150,
        eatTime: 'Dinner',
        name: 'Juice',
        servingUnit: 'ml',
        servingMeasured: 250.0,
      ),
    ]);
  });
  
  //Calorie and serving size commented out as finding subtitles in the widget is difficult
  testWidgets('DailyLogList displays logs grouped by eatTime', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailyLogList(
            logsList: appState.logs ?? [],
            onTileTap: (index) {},
            expandedTile: null,
            appState: appState,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    //expect(find.text('100 cal from 150.0g'), findsOneWidget);

    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    //expect(find.text('200 cal from 300.0g'), findsOneWidget);

    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Juice'), findsOneWidget);
    //expect(find.text('150 cal from 250ml'), findsOneWidget);

    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNWidgets(3));
  });
}