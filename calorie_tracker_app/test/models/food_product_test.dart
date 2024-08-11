import 'package:calorie_tracker_app/models/food_product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FoodProduct Tests', () {
    late FoodProduct foodProduct;

    setUp(() {
      foodProduct = FoodProduct(
        name: 'Banana',
        calories: 105,
        servingSize: '118g',
        quantity: '1 medium',
        totalFat: 0.3,
        saturatedFat: 0.1,
        transFat: 0.0,
        cholesterol: 0,
        sodium: 1,
        totalCarbohydrates: 27.0,
        dietaryFiber: 3.1,
        sugars: 14.0,
        proteins: 1.3,
        imageUrl: 'https://example.com/banana.jpg',
        foodId: '1234567890',
      );
    });

    test('FoodProduct constructor initializes fields correctly', () {
      expect(foodProduct.name, 'Banana');
      expect(foodProduct.calories, 105);
      expect(foodProduct.servingSize, '118g');
      expect(foodProduct.quantity, '1 medium');
      expect(foodProduct.totalFat, 0.3);
      expect(foodProduct.saturatedFat, 0.1);
      expect(foodProduct.transFat, 0.0);
      expect(foodProduct.cholesterol, 0);
      expect(foodProduct.sodium, 1);
      expect(foodProduct.totalCarbohydrates, 27.0);
      expect(foodProduct.dietaryFiber, 3.1);
      expect(foodProduct.sugars, 14.0);
      expect(foodProduct.proteins, 1.3);
      expect(foodProduct.imageUrl, 'https://example.com/banana.jpg');
      expect(foodProduct.foodId, '1234567890');
    });
  });
}