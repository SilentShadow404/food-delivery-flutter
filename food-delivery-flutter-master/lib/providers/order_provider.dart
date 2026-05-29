import 'package:flutter/material.dart';
import 'package:zomato/models/order_model.dart';
import 'package:zomato/models/cart_item_model.dart';
import 'package:zomato/services/api_service.dart';
import 'package:zomato/services/logger_service.dart';
import 'package:zomato/services/notification_service.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get allOrders => _orders;

  List<OrderModel> getCustomerOrders(String customerId) =>
      _orders.where((o) => o.customerId == customerId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<OrderModel> getVendorOrders(String vendorId) =>
      _orders.where((o) => o.vendorId == vendorId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<OrderModel?> placeOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String vendorId,
    required String vendorName,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double deliveryFee,
    required double total,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    final payload = {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'total': total,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
    };
    final res = await ApiService.placeOrder(payload);
    if (res.containsKey('error')) return null;
    // If API doesn't return the created order, we construct a local one
    final created = res['order'] as Map<String, dynamic>?;
    OrderModel? order;
    if (created != null) {
      order = OrderModel.fromMap(created);
    } else {
      // build from payload
      order = OrderModel(
        id: res['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        vendorId: vendorId,
        vendorName: vendorName,
        items: List.from(items),
        subtotal: subtotal,
        tax: tax,
        deliveryFee: deliveryFee,
        total: total,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );
    }
    _orders.add(order);
    log.info(
        '[Orders] Order placed: ${order.id} total=Rs${order.total.toInt()}');
    await notifications.showOrderNotification(
      title: 'Order Placed! 🎉',
      body: 'Your order from ${order.vendorName} is being processed.',
      payload: order.id,
    );
    notifyListeners();
    return order;
  }

  Future<void> loadCustomerOrders(String customerId) async {
    final res = await ApiService.getCustomerOrders(customerId);
    if (res.containsKey('error')) return;
    final list = res['orders'] as List<dynamic>? ?? [];
    _orders.clear();
    for (final it in list) {
      if (it is Map<String, dynamic>) _orders.add(OrderModel.fromMap(it));
    }
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].status = status;
      if (status == OrderStatus.delivered) {
        _orders[idx].deliveredAt = DateTime.now();
      }
      log.info('[Orders] Status updated: $orderId → ${status.name}');
      // Notify customer when their order status changes
      final statusLabel = _statusLabel(status);
      notifications.showOrderNotification(
        title: 'Order Update 📦',
        body: 'Your order is now: $statusLabel',
        payload: orderId,
      );
      notifyListeners();
    }
  }

  static String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed ✅';
      case OrderStatus.preparing:
        return 'Being prepared 🍳';
      case OrderStatus.ready:
        return 'Ready for pickup 🛍';
      case OrderStatus.onTheWay:
        return 'On the way 🛵';
      case OrderStatus.delivered:
        return 'Delivered 🎉';
      case OrderStatus.cancelled:
        return 'Cancelled ❌';
    }
  }

  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  // Stats for admin/vendor dashboards
  int get totalOrders => _orders.length;
  int get activeOrders => _orders
      .where((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled)
      .length;
  double get totalRevenue => _orders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0, (sum, o) => sum + o.total);

  int vendorTotalOrders(String vendorId) =>
      _orders.where((o) => o.vendorId == vendorId).length;
  int vendorActiveOrders(String vendorId) => _orders
      .where((o) =>
          o.vendorId == vendorId &&
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled)
      .length;
  double vendorRevenue(String vendorId) => _orders
      .where((o) => o.vendorId == vendorId && o.status == OrderStatus.delivered)
      .fold(0, (sum, o) => sum + o.total);
}
