import 'package:zomato/models/food_item_model.dart';

class CartItem {
  final FoodItem food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});

  double get totalPrice => food.discountedPrice * quantity;
  Map<String, dynamic> toMap() => {
        'food': food.toMap(),
        'quantity': quantity,
      };

  factory CartItem.fromMap(Map<String, dynamic> m) {
    final foodMap = (m['food'] is Map<String, dynamic>)
        ? m['food'] as Map<String, dynamic>
        : <String, dynamic>{};
    return CartItem(
        food: FoodItem.fromMap(foodMap),
        quantity: (m['quantity'] is int)
            ? m['quantity']
            : ((m['quantity'] is num) ? (m['quantity'] as num).toInt() : 1));
  }
}
