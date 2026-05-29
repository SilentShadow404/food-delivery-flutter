import 'package:flutter/material.dart';
import 'package:zomato/models/food_item_model.dart';
import 'package:zomato/models/cart_item_model.dart';
import 'package:zomato/services/api_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * 0.05; // 5% tax
  double get deliveryFee => _items.isEmpty ? 0 : 50; // flat Rs 50
  double get total => subtotal + tax + deliveryFee;

  Future<void> loadCart(String customerId) async {
    final res = await ApiService.getCart(customerId);
    if (res.containsKey('error')) return;
    final list = res['items'] as List<dynamic>? ?? [];
    _items.clear();
    for (final it in list) {
      if (it is Map<String, dynamic>) _items.add(CartItem.fromMap(it));
    }
    notifyListeners();
  }

  Future<bool> addItem(FoodItem food,
      [String? customerId, int quantity = 1]) async {
    if (customerId != null) {
      final res = await ApiService.addToCart(customerId, food.id, quantity);
      if (res.containsKey('error')) return false;
      await loadCart(customerId);
      return true;
    }
    final idx = _items.indexWhere((item) => item.food.id == food.id);
    if (idx >= 0) {
      _items[idx].quantity += quantity;
    } else {
      _items.add(CartItem(food: food, quantity: quantity));
    }
    notifyListeners();
    return true;
  }

  Future<bool> removeItem(String foodId, [String? customerId]) async {
    if (customerId != null) {
      final res = await ApiService.removeFromCart(customerId, foodId);
      if (res.containsKey('error')) return false;
      await loadCart(customerId);
      return true;
    }
    _items.removeWhere((item) => item.food.id == foodId);
    notifyListeners();
    return true;
  }

  void increaseQty(String foodId) {
    final idx = _items.indexWhere((item) => item.food.id == foodId);
    if (idx >= 0) {
      _items[idx].quantity++;
      notifyListeners();
    }
  }

  void decreaseQty(String foodId) {
    final idx = _items.indexWhere((item) => item.food.id == foodId);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int getQuantity(String foodId) {
    final idx = _items.indexWhere((item) => item.food.id == foodId);
    return idx >= 0 ? _items[idx].quantity : 0;
  }
}
