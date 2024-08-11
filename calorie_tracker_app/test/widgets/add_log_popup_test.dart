import 'package:calorie_tracker_app/models/log.dart';
import 'package:calorie_tracker_app/models/user_settings.dart';
import 'package:calorie_tracker_app/widgets/add_log_popup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calorie_tracker_app/app_state.dart';
import 'package:calorie_tracker_app/models/food_product.dart';

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
  group('AddLogPopup Tests', () {
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
    testWidgets('displays AddFoodLogPopup with FoodProduct info', (WidgetTester tester) async {
      final foodProduct = FoodProduct(
        name: 'Banana',
        calories: 105,
        servingSize: '118g',
        quantity: '1',
        totalFat: 0.3,
        saturatedFat: 0.1,
        transFat: 0.0,
        cholesterol: 0,
        sodium: 1,
        totalCarbohydrates: 27.0,
        dietaryFiber: 3.1,
        sugars: 14.0,
        proteins: 1.3,
        imageUrl: 'https://example.com/banana.jpg',
        foodId: '1234567890',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddFoodLogPopup(
              product: foodProduct,
              appState: appState,
            ),
          ),
        ),
      );

      expect(find.text('Banana - 1\n105 cals per 118g'), findsOneWidget);
    });
  });
}