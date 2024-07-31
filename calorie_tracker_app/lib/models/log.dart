import 'package:cloud_firestore/cloud_firestore.dart';

class Log {
  Log({required this.foodId,
    required this.calories,
    required this.eatTime,
    required this.name,});

  String foodId;    // Unique ID for the food item
  int calories;     // Number of calories
  String eatTime;   // Time when the food was eaten (e.g., breakfast, lunch, dinner, snack)
  String name;      // Name of the food item

  //Note.fromFirestore: Creates a Log instance from a Firestore DocumentSnapshot.
  factory Log.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Log(
      foodId: snapshot.id,             // Use the document ID as foodId
      calories: data?['calories'],
      eatTime: data?['eatTime'],
      name: data?['name'],
    );
  }

  //toMap: Converts the Note into a Map suitable for storing in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'eatTime': eatTime,
      'name': name,
    };
  }
}