import 'package:flutter/material.dart';
import 'package:zomato/models/food_item_model.dart';
import 'package:zomato/models/review_model.dart';
import 'package:zomato/services/api_service.dart';
import 'package:zomato/services/logger_service.dart';
import 'package:zomato/services/meal_db_service.dart';

class FoodProvider extends ChangeNotifier {
  List<FoodItem> _foods = [];
  List<ReviewModel> _reviews = [];
  int _nextReviewId = 20;
  Map<String, String> _mealDbImages = {};

  FoodProvider() {
    fetchFoods();
    _loadMealDbCategories();
  }

  List<FoodItem> get allFoods => _foods;
  List<ReviewModel> get allReviews => _reviews;
  List<String> get categories =>
      ['All', ..._foods.map((f) => f.category).toSet().toList()];

  /// Category → thumbnail URL (from TheMealDB external API).
  Map<String, String> get categoryImages => _mealDbImages;

  Future<void> _loadMealDbCategories() async {
    final images = await mealDb.fetchMappedCategoryImages();
    if (images.isNotEmpty) {
      _mealDbImages = images;
      log.info('[FoodProvider] MealDB category images loaded: ${images.keys}');
      notifyListeners();
    }
  }

  int get nextFoodId {
    final maxId = _foods
        .map((f) => int.tryParse(f.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .fold(0, (a, b) => a > b ? a : b);
    return maxId + 1;
  }

  List<FoodItem> getFoodsByCategory(String category) {
    if (category == 'All') return _foods.where((f) => f.isAvailable).toList();
    return _foods
        .where((f) => f.category == category && f.isAvailable)
        .toList();
  }

  List<FoodItem> getFoodsByVendor(String vendorId) =>
      _foods.where((f) => f.vendorId == vendorId).toList();

  List<FoodItem> searchFoods(String query) {
    final q = query.toLowerCase();
    return _foods
        .where((f) =>
            f.isAvailable &&
            (f.name.toLowerCase().contains(q) ||
                f.category.toLowerCase().contains(q) ||
                f.vendorName.toLowerCase().contains(q)))
        .toList();
  }

  List<FoodItem> get popularFoods {
    final sorted = _foods.where((f) => f.isAvailable).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(8).toList();
  }

  List<FoodItem> get discountedFoods =>
      _foods.where((f) => f.isAvailable && f.discount > 0).toList();

  List<ReviewModel> getReviewsForFood(String foodId) =>
      _reviews.where((r) => r.foodId == foodId).toList();
  void addReview(ReviewModel review) {
    _reviews.add(review);
    // Update food rating
    final foodReviews = getReviewsForFood(review.foodId);
    final avgRating =
        foodReviews.fold(0.0, (sum, r) => sum + r.rating) / foodReviews.length;
    final idx = _foods.indexWhere((f) => f.id == review.foodId);
    if (idx >= 0) {
      _foods[idx] = _foods[idx].copyWith(
        rating: double.parse(avgRating.toStringAsFixed(1)),
        reviewCount: foodReviews.length,
      );
    }
    notifyListeners();
  }

  String get nextReviewId => 'r${_nextReviewId++}';

  // Fetch foods from backend
  Future<void> fetchFoods({String? category, String? vendorId}) async {
    log.info('[FoodProvider] fetchFoods category=$category vendorId=$vendorId');
    final res =
        await ApiService.getFoods(category: category, vendorId: vendorId);
    if (res.containsKey('error')) {
      log.warning('[FoodProvider] fetchFoods error: ${res['error']}');
      return;
    }
    final list = res['foods'] as List<dynamic>? ?? [];
    _foods = list
        .whereType<Map<String, dynamic>>()
        .map((m) => FoodItem.fromMap(m))
        .toList();
    log.info('[FoodProvider] Loaded ${_foods.length} food items.');
    notifyListeners();
  }

  // Vendor: add food
  Future<bool> addFood(FoodItem food) async {
    final res = await ApiService.addFood(food.toMap());
    if (res.containsKey('error')) return false;
    await fetchFoods();
    return true;
  }

  // Vendor: update food
  Future<bool> updateFood(FoodItem updated) async {
    final res = await ApiService.updateFood(updated.id, updated.toMap());
    if (res.containsKey('error')) return false;
    final idx = _foods.indexWhere((f) => f.id == updated.id);
    if (idx >= 0) {
      _foods[idx] = updated;
      notifyListeners();
    }
    return true;
  }

  // Vendor: toggle availability
  Future<void> toggleAvailability(String foodId) async {
    final idx = _foods.indexWhere((f) => f.id == foodId);
    if (idx >= 0) {
      final curr = _foods[idx];
      final updated = curr.copyWith(isAvailable: !curr.isAvailable);
      await updateFood(updated);
    }
  }

  // Vendor: delete food (not implemented server-side)
  Future<void> deleteFood(String foodId) async {
    _foods.removeWhere((f) => f.id == foodId);
    notifyListeners();
  }
}
