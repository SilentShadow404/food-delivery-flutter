import 'package:flutter/material.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/screens/admin/admin_dashboard.dart';
import 'package:zomato/screens/admin/user_management_screen.dart';
import 'package:zomato/screens/admin/vendor_management_screen.dart';
import 'package:zomato/screens/admin/admin_profile_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;
  final _pages = const [
    AdminDashboard(),
    UserManagementScreen(),
    VendorManagementScreen(),
    AdminProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.adminColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storefront), label: 'Vendors'),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings), label: 'Profile'),
        ],
      ),
    );
  }
}
