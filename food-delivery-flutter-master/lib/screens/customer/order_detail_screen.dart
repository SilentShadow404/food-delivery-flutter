import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/order_model.dart';
import 'package:zomato/providers/order_provider.dart';
import 'package:zomato/services/encryption_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Watch for status changes
    context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Order ${order.id}'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Status tracker
          _buildStatusTracker(),
          SizedBox(height: 24),

          // Vendor info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(Icons.store, color: AppColors.primary, size: 28),
              SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.vendorName,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Vendor',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ]),
            ]),
          ),
          SizedBox(height: 16),

          // Items
          Text('Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ...order.items.map((item) => Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildOrderItemImage(item.food.imagePath)),
                  SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(item.food.name,
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                            '${item.quantity} x Rs ${item.food.discountedPrice.toInt()}',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ])),
                  Text('Rs ${item.totalPrice.toInt()}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
              )),
          SizedBox(height: 16),

          // Delivery address
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.location_on, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Delivery Address',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    // Decrypt the stored address before displaying
                    Text(crypto.decryptSafe(order.deliveryAddress),
                        style: TextStyle(color: AppColors.textSecondary)),
                  ])),
            ]),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(Icons.payment, color: AppColors.primary),
              SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Payment Method',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(order.paymentMethod,
                    style: TextStyle(color: AppColors.textSecondary)),
              ]),
            ]),
          ),
          SizedBox(height: 16),

          // Price breakdown
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _priceRow('Subtotal', 'Rs ${order.subtotal.toInt()}'),
              _priceRow('Tax', 'Rs ${order.tax.toInt()}'),
              _priceRow('Delivery Fee', 'Rs ${order.deliveryFee.toInt()}'),
              Divider(height: 20),
              _priceRow('Total', 'Rs ${order.total.toInt()}', bold: true),
            ]),
          ),
          SizedBox(height: 16),

          // Cancel button
          if (order.status == OrderStatus.pending)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  context.read<OrderProvider>().cancelOrder(order.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Order cancelled'),
                      backgroundColor: AppColors.error));
                  Navigator.pop(context);
                },
                icon: Icon(Icons.cancel, color: AppColors.error),
                label: Text('Cancel Order',
                    style: TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.bold)),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _buildStatusTracker() {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.onTheWay,
      OrderStatus.delivered
    ];
    final currentIdx = order.status == OrderStatus.cancelled
        ? -1
        : statuses.indexOf(order.status);

    if (order.status == OrderStatus.cancelled) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.error.withAlpha(20),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(Icons.cancel, color: AppColors.error, size: 32),
          SizedBox(width: 12),
          Text('Order Cancelled',
              style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ]),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text('Order Status',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        ...List.generate(statuses.length, (i) {
          final done = i <= currentIdx;
          final isCurrent = i == currentIdx;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? AppColors.success : AppColors.divider),
                child: done
                    ? Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              if (i < statuses.length - 1)
                Container(
                    width: 2,
                    height: 30,
                    color: done ? AppColors.success : AppColors.divider),
            ]),
            SizedBox(width: 12),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(orderStatusToString(statuses[i]),
                  style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: done ? AppColors.textPrimary : AppColors.textHint,
                      fontSize: isCurrent ? 15 : 14)),
            ),
          ]);
        }),
      ]),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                color: bold ? null : AppColors.textSecondary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: bold ? AppColors.primary : null)),
      ]),
    );
  }

  Widget _buildOrderItemImage(String path) {
    if (path.startsWith('/') || path.startsWith('file://')) {
      final file = File(path.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(file, width: 50, height: 50, fit: BoxFit.cover);
      }
    }
    return Image.asset(path,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
            width: 50,
            height: 50,
            color: Colors.grey[200],
            child: Icon(Icons.fastfood, size: 24, color: Colors.grey)));
  }
}
