import 'package:calorie_tracker_app/models/food_product.dart';
import 'package:calorie_tracker_app/models/log.dart';
import 'package:flutter/material.dart';

/// Builds a scrollable container which displays various information of the FoodProduct and if available, the Log entry
/// The widget will display accessible information about the FoodProduct such as Nutritional information and an Image
/// If a Log entry is provided, it will display the calories and servings consumed by the user for that Log entry
/// Arguments:
/// - singleProduct: The FoodProduct to display information of
/// - log: A log entry if available, to get access to consumption info
class ProductLogView extends StatelessWidget {
  final FoodProduct? singleProduct;
  final Log? log;

  const ProductLogView({
    super.key,
    required this.singleProduct,
    this.log,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (singleProduct?.imageUrl?.isNotEmpty ?? false)
              SizedBox(
                width: 400,
                height: 400,
                child: Image.network(
                  singleProduct?.imageUrl ?? '',
                  fit: BoxFit.contain,
                ),
              ),
            Text("Barcode ID: ${singleProduct?.foodId}", style: const TextStyle(color: Colors.white)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (singleProduct?.imageUrl?.isNotEmpty ?? false)
                  const SizedBox(height: 40), //Padding
                Text(
                  'Serving Size: ${singleProduct?.calories.toString() ?? 'Unknown'} cals per ${singleProduct?.servingSize ?? 'Unknown'}.',
                  style: const TextStyle(color: Colors.white),
                ),
                if (log != null)
                Text(
                  "You logged: ${log?.calories.toString()} calories from ${log?.servingMeasured.toString()}${log?.servingUnit}",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20), //Padding
            const Text('Nutritional Facts', style: TextStyle(color: Colors.white, fontSize: 17)),
            const SizedBox(height: 20), //Padding
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Fat: ${singleProduct?.totalFat != null ? '${singleProduct!.totalFat.toString()} g' : 'No data'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '      Saturated Fat: ${singleProduct?.saturatedFat != null ? '${singleProduct!.saturatedFat.toString()} g' : 'No data'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '      Trans Fat: ${singleProduct?.transFat != null ? '${singleProduct!.transFat.toString()} g' : 'No data'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Cholesterol: ${singleProduct?.cholesterol != null ? '${singleProduct!.cholesterol.toString()} mg' : 'No data'}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sodium: ${singleProduct?.sodium != null ? '${singleProduct!.sodium.toString()} mg' : 'No data'}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Carbohydrates: ${singleProduct?.totalCarbohydrates != null ? '${singleProduct!.totalCarbohydrates.toString()} g' : 'No data'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '      Dietary Fiber: ${singleProduct?.dietaryFiber != null ? '${singleProduct!.dietaryFiber.toString()} g' : 'No data'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '      Sugars: ${singleProduct?.sugars != null ? '${singleProduct!.sugars.toString()} g' : 'No data'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Proteins: ${singleProduct?.proteins != null ? '${singleProduct!.proteins.toString()} g' : 'No data'}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}