import 'package:zomato/models/cart_item_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  onTheWay,
  delivered,
  cancelled
}

String orderStatusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'Pending';
    case OrderStatus.confirmed:
      return 'Confirmed';
    case OrderStatus.preparing:
      return 'Preparing';
    case OrderStatus.ready:
      return 'Ready for Pickup';
    case OrderStatus.onTheWay:
      return 'On the Way';
    case OrderStatus.delivered:
      return 'Delivered';
    case OrderStatus.cancelled:
      return 'Cancelled';
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String vendorId;
  final String vendorName;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  OrderStatus status;
  final String deliveryAddress;
  final String paymentMethod;
  final DateTime createdAt;
  DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.vendorId,
    required this.vendorName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    this.status = OrderStatus.pending,
    required this.deliveryAddress,
    required this.paymentMethod,
    DateTime? createdAt,
    this.deliveredAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
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
        'status': status.toString().split('.').last,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'createdAt': createdAt.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
      };

  static OrderModel fromMap(Map<String, dynamic> m) {
    OrderStatus parseStatus(String? s) {
      switch (s) {
        case 'confirmed':
          return OrderStatus.confirmed;
        case 'preparing':
          return OrderStatus.preparing;
        case 'ready':
          return OrderStatus.ready;
        case 'onTheWay':
          return OrderStatus.onTheWay;
        case 'delivered':
          return OrderStatus.delivered;
        case 'cancelled':
          return OrderStatus.cancelled;
        default:
          return OrderStatus.pending;
      }
    }

    final itemsList = <CartItem>[];
    if (m['items'] is List) {
      for (final it in (m['items'] as List)) {
        if (it is Map<String, dynamic>) itemsList.add(CartItem.fromMap(it));
      }
    }

    return OrderModel(
      id: m['id']?.toString() ?? '',
      customerId: m['customerId']?.toString() ?? '',
      customerName: m['customerName']?.toString() ?? '',
      customerPhone: m['customerPhone']?.toString() ?? '',
      vendorId: m['vendorId']?.toString() ?? '',
      vendorName: m['vendorName']?.toString() ?? '',
      items: itemsList,
      subtotal:
          (m['subtotal'] is num) ? (m['subtotal'] as num).toDouble() : 0.0,
      tax: (m['tax'] is num) ? (m['tax'] as num).toDouble() : 0.0,
      deliveryFee: (m['deliveryFee'] is num)
          ? (m['deliveryFee'] as num).toDouble()
          : 0.0,
      total: (m['total'] is num) ? (m['total'] as num).toDouble() : 0.0,
      status: parseStatus(m['status']?.toString()),
      deliveryAddress: m['deliveryAddress']?.toString() ?? '',
      paymentMethod: m['paymentMethod']?.toString() ?? '',
      createdAt: m['createdAt'] != null
          ? DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      deliveredAt: m['deliveredAt'] != null
          ? DateTime.tryParse(m['deliveredAt'].toString())
          : null,
    );
  }
}
