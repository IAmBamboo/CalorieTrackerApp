import 'package:cloud_firestore/cloud_firestore.dart';

class Log {
  Log({required this.foodId,
    required this.calories,
    required this.eatTime,
    required this.name,
    required this.servingUnit,
    required this.servingMeasured,
    this.id
    });

  String? id;       // Unique ID for the log
  String foodId;    // Barcode ID for the food item used to find it in OpenFoodFact's database
  String name;      // Name of the food item
  int calories;     // Number of calories
  String eatTime;   // Time when the food was eaten (e.g., breakfast, lunch, dinner, snack)
  String servingUnit; // The unit of measurement for its serving size
  double servingMeasured; // The number of consumed of the servingUnit (e.g., 100 of grams or 358 of mL)

  //Note.fromFirestore: Creates a Log instance from a Firestore DocumentSnapshot.
  factory Log.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Log(
      id: snapshot.id,
      foodId: data?['foodId'],
      calories: data?['calories'],
      eatTime: data?['eatTime'],
      name: data?['name'],
      servingUnit: data?['servingUnit'],
      servingMeasured: (data?['servingMeasured'] as num).toDouble(),
    );
  }

  //toMap: Converts the Note into a Map suitable for storing in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'eatTime': eatTime,
      'name': name,
      'foodId': foodId,
      'servingUnit': servingUnit,
      'servingMeasured': servingMeasured,
    };
  }
}