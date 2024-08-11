import 'package:calorie_tracker_app/models/log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Log Tests', () {
    late Log log;

    setUp(() {
      log = Log(
        id: 'testId123',
        foodId: 'food123',
        name: 'Apple',
        calories: 95,
        eatTime: 'Breakfast',
        servingUnit: 'grams',
        servingMeasured: 182.0,
      );
    });

    test('Log constructor initializes fields correctly', () {
      expect(log.id, 'testId123');
      expect(log.foodId, 'food123');
      expect(log.name, 'Apple');
      expect(log.calories, 95);
      expect(log.eatTime, 'Breakfast');
      expect(log.servingUnit, 'grams');
      expect(log.servingMeasured, 182.0);
    });

    test('toMap() returns correct map', () {
      final map = log.toMap();
      expect(map['foodId'], 'food123');
      expect(map['name'], 'Apple');
      expect(map['calories'], 95);
      expect(map['eatTime'], 'Breakfast');
      expect(map['servingUnit'], 'grams');
      expect(map['servingMeasured'], 182.0);
    });

    test('fromFirestore() creates Log object correctly', () {
      final data = {
        'foodId': 'food123',
        'name': 'Apple',
        'calories': 95,
        'eatTime': 'Breakfast',
        'servingUnit': 'grams',
        'servingMeasured': 182.0,
      };

      final snapshot = FakeDocumentSnapshot<Map<String, dynamic>>(
        id: 'testId123',
        data: data,
      );

      final logFromFirestore = Log.fromFirestore(snapshot);
      expect(logFromFirestore.id, 'testId123');
      expect(logFromFirestore.foodId, 'food123');
      expect(logFromFirestore.name, 'Apple');
      expect(logFromFirestore.calories, 95);
      expect(logFromFirestore.eatTime, 'Breakfast');
      expect(logFromFirestore.servingUnit, 'grams');
      expect(logFromFirestore.servingMeasured, 182.0);
    });
  });
}

// Fake DocumentSnapshot for testing
// ignore: subtype_of_sealed_class
class FakeDocumentSnapshot<T> extends DocumentSnapshot<T> {
  @override
  final String id;
  final T? _data;

  FakeDocumentSnapshot({required this.id, T? data}) : _data = data;

  @override
  T? data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}