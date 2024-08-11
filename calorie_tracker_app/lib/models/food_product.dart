class FoodProduct {
  FoodProduct({
    required this.calories,
    required this.servingSize,
    required this.name,
    required this.quantity,
    required this.totalFat,
    required this.saturatedFat,
    required this.transFat,
    required this.cholesterol,
    required this.sodium,
    required this.totalCarbohydrates,
    required this.dietaryFiber,
    required this.sugars,
    required this.proteins,
    required this.imageUrl,
    required this.foodId,
    });

  final String name; // Name of the food product
  final int? calories;
  final String? servingSize; // Serving size of the food product (ex. 150g, 20mL, 2kg)
  final String? quantity;
  final double? totalFat;
  final double? saturatedFat;
  final double? transFat;
  final int? cholesterol;
  final int? sodium;
  final double? totalCarbohydrates;
  final double? dietaryFiber;
  final double? sugars;
  final double? proteins;
  final String? imageUrl; // String URL of the image from OpenFoodFact's database
  final String? foodId; // Barcode ID for the food item used to find it in OpenFoodFact's database
}