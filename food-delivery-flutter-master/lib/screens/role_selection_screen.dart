import 'package:flutter/material.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/user_model.dart';
import 'package:zomato/screens/auth/login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(height: 40),
                Icon(Icons.restaurant_menu, size: 60, color: AppColors.primary),
                SizedBox(height: 16),
                Text('Welcome to MiniZomato',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('How would you like to continue?',
                    style: TextStyle(
                        fontSize: 16, color: AppColors.textSecondary)),
                SizedBox(height: 50),
                _RoleCard(
                  title: 'Customer',
                  subtitle: 'Browse restaurants, order food, track delivery',
                  icon: Icons.person,
                  color: AppColors.primary,
                  onTap: () => _navigateToLogin(context, UserRole.customer),
                ),
                SizedBox(height: 20),
                _RoleCard(
                  title: 'Vendor / Restaurant',
                  subtitle: 'Manage your menu, receive & process orders',
                  icon: Icons.store,
                  color: AppColors.vendorColor,
                  onTap: () => _navigateToLogin(context, UserRole.vendor),
                ),
                SizedBox(height: 20),
                _RoleCard(
                  title: 'Admin',
                  subtitle: 'Manage users, vendors, and monitor system',
                  icon: Icons.admin_panel_settings,
                  color: AppColors.adminColor,
                  onTap: () => _navigateToLogin(context, UserRole.admin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, UserRole role) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => LoginScreen(role: role)));
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(60)),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(25),
                blurRadius: 10,
                offset: Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
