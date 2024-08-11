class FoodProduct {
  FoodProduct({
    required this.calories,
    required this.servingSize,
    required this.name,
    required this.quantity,
    required this.imageUrl,
    required this.foodId,
    });

  final String name;
  final int? calories;
  final String? servingSize;
  final String? quantity;
  final String? imageUrl;
  final String? foodId; // Barcode ID for the food item used to find it in OpenFoodFact's database
}