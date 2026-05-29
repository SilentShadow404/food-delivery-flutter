import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/order_provider.dart';
import 'package:zomato/screens/vendor/vendor_dashboard.dart';
import 'package:zomato/screens/vendor/menu_management_screen.dart';
import 'package:zomato/screens/vendor/vendor_orders_screen.dart';
import 'package:zomato/screens/vendor/vendor_profile_screen.dart';
import 'package:zomato/services/background_service.dart';

class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({super.key});

  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  int _currentIndex = 0;
  final _pages = const [
    VendorDashboard(),
    MenuManagementScreen(),
    VendorOrdersScreen(),
    VendorProfileScreen()
  ];

  @override
  void initState() {
    super.initState();
    // Register periodic background task to check new vendor orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vendorId = context.read<AuthProvider>().currentUser?.id ?? '';
      if (vendorId.isNotEmpty) {
        backgroundService.registerVendorOrderCheck(vendorId);
        context.read<OrderProvider>().loadVendorOrders(vendorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.vendorColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
