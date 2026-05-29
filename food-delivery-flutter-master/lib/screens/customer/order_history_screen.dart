import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/order_model.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/order_provider.dart';
import 'package:zomato/screens/customer/order_detail_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders =
        context.watch<OrderProvider>().getCustomerOrders(auth.currentUser!.id);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text('My Orders',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: orders.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 80, color: Colors.grey[300]),
                          SizedBox(height: 16),
                          Text('No orders yet',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary)),
                          SizedBox(height: 8),
                          Text('Your order history will appear here',
                              style: TextStyle(color: AppColors.textHint)),
                        ]))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: orders.length,
                      itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))),
      child: Container(
        margin: EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(order.id,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            _StatusChip(status: order.status),
          ]),
          SizedBox(height: 8),
          Row(children: [
            Icon(Icons.store, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 4),
            Text(order.vendorName,
                style: TextStyle(color: AppColors.textSecondary)),
          ]),
          SizedBox(height: 4),
          Text('${order.items.length} item(s)  •  Rs ${order.total.toInt()}',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.primary)),
          SizedBox(height: 6),
          Text(
              '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}  ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: AppColors.textHint, fontSize: 12)),
        ]),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        break;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        color = AppColors.vendorColor;
        break;
      case OrderStatus.ready:
      case OrderStatus.onTheWay:
        color = AppColors.primary;
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withAlpha(30), borderRadius: BorderRadius.circular(8)),
      child: Text(orderStatusToString(status),
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
