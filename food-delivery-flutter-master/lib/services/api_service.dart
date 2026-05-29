import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _deployedUrl =
      'https://food-delivery-flutter.onrender.com/api';

  static String get _base {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return _deployedUrl; // always use Render.com
  }

  static Uri _uri(String path) => Uri.parse('$_base$path');

  // Auth
  static Future<Map<String, dynamic>> login(
      String email, String password, String role) async {
    final res = await http.post(_uri('/auth/login'),
        body: json.encode({'email': email, 'password': password, 'role': role}),
        headers: {'Content-Type': 'application/json'});
    return _parse(res);
  }

  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> payload) async {
    final res = await http.post(_uri('/auth/register'),
        body: json.encode(payload),
        headers: {'Content-Type': 'application/json'});
    return _parse(res);
  }

  static Future<Map<String, dynamic>> getUsers() async {
    final res = await http.get(_uri('/auth/users'));
    return _parse(res);
  }

  static Future<Map<String, dynamic>> updateUser(
      String id, Map<String, dynamic> payload) async {
    final res = await http.patch(_uri('/auth/users/$id'),
        body: json.encode(payload),
        headers: {'Content-Type': 'application/json'});
    return _parse(res);
  }

  // Foods
  static Future<Map<String, dynamic>> getFoods(
      {String? category, String? vendorId}) async {
    final query = <String, String>{};
    if (category != null) query['category'] = category;
    if (vendorId != null) query['vendorId'] = vendorId;
    final uri = Uri.parse('$_base/foods')
        .replace(queryParameters: query.isEmpty ? null : query);
    final res = await http.get(uri);
    return _parse(res);
  }

  static Future<Map<String, dynamic>> addFood(
      Map<String, dynamic> payload) async {
    final res = await http.post(_uri('/foods'),
        body: json.encode(payload),
        headers: {'Content-Type': 'application/json'});
    return _parse(res);
  }

  static Future<Map<String, dynamic>> updateFood(
      String id, Map<String, dynamic> payload) async {
    final res = await http.put(Uri.parse('$_base/foods/$id'),
        body: json.encode(payload),
        headers: {'Content-Type': 'application/json'});
    return _parse(res);
  }

  // Cart
  static Future<Map<String, dynamic>> getCart(String customerId) async {
    final res = await http.get(_uri('/cart/$customerId'));
    return _parse(res);
  }

  static Future<Map<String, dynamic>> addToCart(
      String customerId, String foodId, int quantity) async {
    final res = await http.post(_uri('/cart/$customerId'),
        body: json.encode({'foodId': foodId, 'quantity': quantity}),
        headers: {'Content-Type': 'application/json'});
    return _parse(res);
  }

  static Future<Map<String, dynamic>> removeFromCart(
      String customerId, String foodId) async {
    final res = await http.delete(_uri('/cart/$customerId/$foodId'));
    return _parse(res);
  }

  // Orders
  static Future<Map<String, dynamic>> placeOrder(
      Map<String, dynamic> payload) async {
    final res = await http.post(_uri('/orders'),
        body: json.encode(payload),
        headers: {'Content-Type': 'application/json'});
    return _parse(res);
  }

  static Future<Map<String, dynamic>> getCustomerOrders(
      String customerId) async {
    final res = await http.get(_uri('/orders/customer/$customerId'));
    return _parse(res);
  }

  static Future<Map<String, dynamic>> getVendorOrders(String vendorId) async {
    final res = await http.get(_uri('/orders/vendor/$vendorId'));
    return _parse(res);
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await http.post(_uri('/auth/forgot-password'),
        body: json.encode({'email': email}),
        headers: {'Content-Type': 'application/json'});
    return _parse(res);
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status) async {
    final res = await http.patch(Uri.parse('$_base/orders/$orderId/status'),
        body: json.encode({'status': status}),
        headers: {'Content-Type': 'application/json'});
    return _parse(res);
  }

  static Future<Map<String, dynamic>> getAllOrders() async {
    final res = await http.get(_uri('/orders/all'));
    return _parse(res);
  }

  static Future<Map<String, dynamic>> deleteFood(String id) async {
    final res = await http.delete(_uri('/foods/$id'));
    return _parse(res);
  }

  static Map<String, dynamic> _parse(http.Response res) {
    try {
      final decoded =
          res.body.isEmpty ? <String, dynamic>{} : json.decode(res.body);
      final body =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      if (res.statusCode >= 200 && res.statusCode < 300) return body;
      return {
        'error': body['error'] ?? 'Request failed',
        'status': res.statusCode
      };
    } catch (e) {
      return {'error': 'Invalid response', 'status': res.statusCode};
    }
  }
}
