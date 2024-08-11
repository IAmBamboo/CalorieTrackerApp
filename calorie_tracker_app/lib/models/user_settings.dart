import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings {
  UserSettings({
    required this.caloriesLimit,
    });

  int caloriesLimit;     // Number of calories

  //Note.fromFirestore: Creates a Log instance from a Firestore DocumentSnapshot.
  factory UserSettings.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return UserSettings(
      caloriesLimit: data?['caloriesLimit'],
    );
  }

  //toMap: Converts the Note into a Map suitable for storing in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'caloriesLimit': caloriesLimit,
    };
  }
}