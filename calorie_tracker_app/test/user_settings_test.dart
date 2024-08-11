import 'package:calorie_tracker_app/models/user_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('UserSettings Tests', () {
    late UserSettings userSettings;

    setUp(() {
      userSettings = UserSettings(
        caloriesLimit: 1800,
      );
    });

    test('UserSettings constructor initializes fields correctly', () {
      expect(userSettings.caloriesLimit, 1800);
    });

    test('toMap() returns correct map', () {
      final map = userSettings.toMap();
      expect(map['caloriesLimit'], 1800);
    });

    test('fromFirestore() creates UserSettings object correctly', () {
      final data = {
        'caloriesLimit': 2500,
      };

      final snapshot = createDocumentSnapshot('userSettingsId', data);

      final userSettingsFromFirestore = UserSettings.fromFirestore(snapshot);
      expect(userSettingsFromFirestore.caloriesLimit, 2500);
    });
  });
}

// Helper function to create a DocumentSnapshot for testing
DocumentSnapshot<Map<String, dynamic>> createDocumentSnapshot(
    String id, Map<String, dynamic> data) {
  return FakeDocumentSnapshot(id, data);
}

// Fake DocumentSnapshot for testing
// ignore: subtype_of_sealed_class
class FakeDocumentSnapshot extends DocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic> _data;

  FakeDocumentSnapshot(this._id, this._data);

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => _id;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  DocumentReference<Map<String, dynamic>> get reference =>
      throw UnimplementedError();

  @override
  bool get exists => true;

  @override
  dynamic operator [](Object field) => _data[field];

  @override
  dynamic get(Object field) => _data[field];
}