import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/order_provider.dart';
import 'package:zomato/providers/food_provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();
    final foods = context.watch<FoodProvider>();
    final user = auth.currentUser!;

    final totalUsers = auth.customers.length;
    final totalVendors = auth.approvedVendors.length;
    final pendingVendors = auth.pendingVendors.length;
    final totalOrders = orders.totalOrders;
    final totalRevenue = orders.totalRevenue;
    final totalFoodItems = foods.allFoods.length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Text('Admin Panel',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            SizedBox(height: 4),
            Text('Hi, ${user.name}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),

            // Stats Grid
            Row(children: [
              _AdminStatCard(
                  label: 'Customers',
                  value: '$totalUsers',
                  icon: Icons.people,
                  color: AppColors.vendorColor),
              SizedBox(width: 14),
              _AdminStatCard(
                  label: 'Vendors',
                  value: '$totalVendors',
                  icon: Icons.store,
                  color: AppColors.primary),
            ]),
            SizedBox(height: 14),
            Row(children: [
              _AdminStatCard(
                  label: 'Pending',
                  value: '$pendingVendors',
                  icon: Icons.pending,
                  color: AppColors.warning),
              SizedBox(width: 14),
              _AdminStatCard(
                  label: 'Total Orders',
                  value: '$totalOrders',
                  icon: Icons.receipt,
                  color: AppColors.adminColor),
            ]),
            SizedBox(height: 14),
            Row(children: [
              _AdminStatCard(
                  label: 'Revenue',
                  value: 'Rs ${totalRevenue.toInt()}',
                  icon: Icons.attach_money,
                  color: AppColors.success),
              SizedBox(width: 14),
              _AdminStatCard(
                  label: 'Food Items',
                  value: '$totalFoodItems',
                  icon: Icons.fastfood,
                  color: AppColors.error),
            ]),
            SizedBox(height: 24),

            // Quick Actions
            Text('Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _ActionTile(
                icon: Icons.pending_actions,
                title: 'Pending Vendor Approvals',
                subtitle: '$pendingVendors vendors waiting for approval',
                color: AppColors.warning),
            _ActionTile(
                icon: Icons.bar_chart,
                title: 'System Overview',
                subtitle: '$totalOrders orders from $totalVendors vendors',
                color: AppColors.vendorColor),
            _ActionTile(
                icon: Icons.restaurant_menu,
                title: 'Food Catalog',
                subtitle: '$totalFoodItems items across all vendors',
                color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _AdminStatCard(
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _ActionTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color});

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
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color)),
        SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ])),
        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ]),
    );
  }
}
