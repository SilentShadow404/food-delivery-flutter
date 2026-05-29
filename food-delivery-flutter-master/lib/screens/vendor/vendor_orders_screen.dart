import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/order_model.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/order_provider.dart';

class VendorOrdersScreen extends StatelessWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProv = context.watch<OrderProvider>();
    final orders = orderProv.getVendorOrders(auth.currentUser!.id);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text('Incoming Orders',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: orders.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                          SizedBox(height: 16),
                          Text('No orders received yet',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary)),
                        ]))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: orders.length,
                      itemBuilder: (ctx, i) =>
                          _VendorOrderCard(order: orders[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorOrderCard extends StatelessWidget {
  final OrderModel order;
  const _VendorOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(order.id,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          _statusChip(order.status),
        ]),
        SizedBox(height: 8),
        Row(children: [
          Icon(Icons.person, size: 16, color: AppColors.textSecondary),
          SizedBox(width: 4),
          Text('${order.customerName}  •  ${order.customerPhone}',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ]),
        SizedBox(height: 4),
        Row(children: [
          Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
          SizedBox(width: 4),
          Expanded(
              child: Text(order.deliveryAddress,
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ]),
        SizedBox(height: 8),
        // Items list
        ...order.items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                  '  ${item.quantity}x ${item.food.name} - Rs ${item.totalPrice.toInt()}',
                  style: TextStyle(fontSize: 13)),
            )),
        Divider(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total: Rs ${order.total.toInt()}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary)),
          Text(order.paymentMethod,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ]),
        SizedBox(height: 10),
        // Action buttons based on status
        _buildActions(context, order),
      ]),
    );
  }

  Widget _buildActions(BuildContext context, OrderModel order) {
    final orderProv = context.read<OrderProvider>();
    switch (order.status) {
      case OrderStatus.pending:
        return Row(children: [
          Expanded(
              child: OutlinedButton(
            onPressed: () => orderProv.cancelOrder(order.id),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Reject'),
          )),
          SizedBox(width: 10),
          Expanded(
              child: ElevatedButton(
            onPressed: () =>
                orderProv.updateOrderStatus(order.id, OrderStatus.confirmed),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: Text('Accept', style: TextStyle(color: Colors.white)),
          )),
        ]);
      case OrderStatus.confirmed:
        return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  orderProv.updateOrderStatus(order.id, OrderStatus.preparing),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vendorColor),
              child: Text('Start Preparing',
                  style: TextStyle(color: Colors.white)),
            ));
      case OrderStatus.preparing:
        return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  orderProv.updateOrderStatus(order.id, OrderStatus.ready),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('Mark Ready', style: TextStyle(color: Colors.white)),
            ));
      case OrderStatus.ready:
        return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  orderProv.updateOrderStatus(order.id, OrderStatus.onTheWay),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child:
                  Text('Hand to Rider', style: TextStyle(color: Colors.white)),
            ));
      case OrderStatus.onTheWay:
        return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  orderProv.updateOrderStatus(order.id, OrderStatus.delivered),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              child:
                  Text('Mark Delivered', style: TextStyle(color: Colors.white)),
            ));
      default:
        return SizedBox();
    }
  }

  Widget _statusChip(OrderStatus status) {
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
