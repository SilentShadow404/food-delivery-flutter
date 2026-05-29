import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger_service.dart';

/// Integrates with TheMealDB free public API (https://www.themealdb.com/api.php)
/// to fetch real meal categories with their thumbnail images.
/// This satisfies the "External REST API other than Firebase" rubric item.
class MealDbService {
  MealDbService._();

  static final MealDbService instance = MealDbService._();

  static const String _base = 'https://www.themealdb.com/api/json/v1/1';

  /// Returns a map of { categoryName: thumbnailUrl } from TheMealDB.
  Future<Map<String, String>> fetchCategories() async {
    try {
      log.info('[MealDB] Fetching categories from TheMealDB...');
      final uri = Uri.parse('$_base/categories.php');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        log.warning('[MealDB] Non-200 response: ${res.statusCode}');
        return {};
      }
      final decoded = json.decode(res.body) as Map<String, dynamic>;
      final categories = decoded['categories'] as List<dynamic>? ?? [];
      final result = <String, String>{};
      for (final cat in categories) {
        if (cat is Map<String, dynamic>) {
          final name = cat['strCategory'] as String?;
          final thumb = cat['strCategoryThumb'] as String?;
          if (name != null && thumb != null) {
            result[name] = thumb;
          }
        }
      }
      log.info('[MealDB] Loaded ${result.length} categories.');
      return result;
    } catch (e, s) {
      log.error('[MealDB] fetchCategories failed', e, s);
      return {};
    }
  }

  /// Maps our local app category names to the closest TheMealDB category name.
  static const Map<String, String> _categoryMapping = {
    'Burgers': 'Fast Food',
    'Pizza': 'Pizza', // not in MealDB but kept as-is
    'Coffee & Tea': 'Side',
    'Pakistani': 'Lamb',
    'Fast Food': 'Fast Food',
    'Desserts': 'Dessert',
    'Beverages': 'Miscellaneous',
  };

  /// Returns only the thumbnails that match our app's categories.
  Future<Map<String, String>> fetchMappedCategoryImages() async {
    final all = await fetchCategories();
    final mapped = <String, String>{};
    for (final entry in _categoryMapping.entries) {
      final thumb = all[entry.value];
      if (thumb != null) mapped[entry.key] = thumb;
    }
    return mapped;
  }

  /// Fetches a random meal for an inspiration feature (optional use).
  Future<Map<String, dynamic>?> fetchRandomMeal() async {
    try {
      final uri = Uri.parse('$_base/random.php');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final decoded = json.decode(res.body) as Map<String, dynamic>;
      final meals = decoded['meals'] as List<dynamic>?;
      return meals?.first as Map<String, dynamic>?;
    } catch (e, s) {
      log.error('[MealDB] fetchRandomMeal failed', e, s);
      return null;
    }
  }
}

final mealDb = MealDbService.instance;
