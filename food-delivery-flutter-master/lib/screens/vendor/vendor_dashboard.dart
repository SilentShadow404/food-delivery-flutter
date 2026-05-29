import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/order_model.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/order_provider.dart';
import 'package:zomato/providers/food_provider.dart';

class VendorDashboard extends StatelessWidget {
  const VendorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();
    final foods = context.watch<FoodProvider>();
    final user = auth.currentUser!;
    final vendorId = user.id;

    final totalOrders = orders.vendorTotalOrders(vendorId);
    final activeOrders = orders.vendorActiveOrders(vendorId);
    final revenue = orders.vendorRevenue(vendorId);
    final menuItems = foods.getFoodsByVendor(vendorId).length;
    final recentOrders = orders.getVendorOrders(vendorId).take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Text('Welcome back,',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            SizedBox(height: 4),
            Text(user.restaurantName ?? user.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),

            // Stats Grid
            Row(children: [
              _StatCard(
                  label: 'Total Orders',
                  value: '$totalOrders',
                  icon: Icons.receipt,
                  color: AppColors.vendorColor),
              SizedBox(width: 14),
              _StatCard(
                  label: 'Active Orders',
                  value: '$activeOrders',
                  icon: Icons.pending_actions,
                  color: AppColors.primary),
            ]),
            SizedBox(height: 14),
            Row(children: [
              _StatCard(
                  label: 'Revenue',
                  value: 'Rs ${revenue.toInt()}',
                  icon: Icons.attach_money,
                  color: AppColors.success),
              SizedBox(width: 14),
              _StatCard(
                  label: 'Menu Items',
                  value: '$menuItems',
                  icon: Icons.restaurant_menu,
                  color: AppColors.adminColor),
            ]),
            SizedBox(height: 24),

            // Recent Orders
            Text('Recent Orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            if (recentOrders.isEmpty)
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Text('No orders yet',
                        style: TextStyle(color: AppColors.textSecondary))),
              )
            else
              ...recentOrders.map((o) => _RecentOrderTile(order: o)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 8,
                  offset: Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 22)),
          SizedBox(height: 12),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ]),
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final OrderModel order;
  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.vendorColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.receipt, color: AppColors.vendorColor)),
        SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(order.id, style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${order.customerName} • ${order.items.length} items',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Rs ${order.total.toInt()}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
          SizedBox(height: 2),
          Text(orderStatusToString(order.status),
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}
