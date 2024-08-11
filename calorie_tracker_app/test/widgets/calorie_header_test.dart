import 'package:calorie_tracker_app/widgets/calorie_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CalorieHeader displays correct values', (WidgetTester tester) async {
    const totalCalories = 150;
    const caloriesLimit = 500;

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            bottom: const CalorieHeader(
              totalCalories: totalCalories, 
              caloriesLimit: caloriesLimit
            )
          ),
        ),
      ),
    );

    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('350'), findsOneWidget);

    expect(find.text('Consumed'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);

    expect(find.text('Limit'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
  });
}