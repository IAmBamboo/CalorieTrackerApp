import 'package:calorie_tracker_app/widgets/product_log_view.dart';
import 'package:flutter/material.dart';
import 'package:calorie_tracker_app/models/food_product.dart';

void searchResultPopup(BuildContext context, FoodProduct product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 31, 31, 31),
        title: Text(
          '${product.name} ${product.quantity!.isNotEmpty ? '- ${product.quantity}' : ''}',
          style: const TextStyle(
            color: Color.fromARGB(255, 255, 242, 199),
            shadows: <Shadow>[
              Shadow(
                blurRadius: 2,
                color: Color.fromARGB(255, 255, 228, 141),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite, // Make the dialog width stretch to fit the content
          height: 400, // Adjust height as needed
          child: ProductLogView(singleProduct: product),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 30, color: Color.fromARGB(255, 255, 196, 0)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}