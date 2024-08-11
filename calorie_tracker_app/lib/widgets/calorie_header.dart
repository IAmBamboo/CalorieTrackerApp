import 'package:flutter/material.dart';


/// Builds a header with calorie related trackers.
/// It has three trackers, Budget, Consumed, and Limit. All of which uses passed through data and is calculated
///
/// Arguments:
/// - totalCalories: An integer which is the total calories consumed so far.
/// - caloriesLimit: An integer which is the max number of calories for the day
class CalorieHeader extends StatelessWidget implements PreferredSizeWidget {
  final int totalCalories;
  final int caloriesLimit;

  const CalorieHeader({
    Key? key,
    required this.totalCalories,
    required this.caloriesLimit,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 31, 31, 31),
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Budget",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 242, 199),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              Text(
                "${caloriesLimit - totalCalories}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Consumed",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 242, 199),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              Text(
                "$totalCalories",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Limit",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 242, 199),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              Text(
                "$caloriesLimit",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}