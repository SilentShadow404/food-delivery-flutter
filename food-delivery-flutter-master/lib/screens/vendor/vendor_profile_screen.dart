import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/order_provider.dart';
import 'package:zomato/widgets/custom_button.dart';
import 'package:zomato/widgets/custom_text_field.dart';
import 'package:zomato/widgets/rating_stars.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.store_outlined,
                      size: 64, color: AppColors.vendorColor),
                  const SizedBox(height: 16),
                  const Text(
                    'Not logged in',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please log in to view the vendor profile.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Go to Login',
                    color: AppColors.vendorColor,
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/role-selection',
                      (_) => false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final orderCount =
        context.watch<OrderProvider>().vendorTotalOrders(user.id);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            SizedBox(height: 10),
            CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.vendorColor.withAlpha(30),
                child:
                    Icon(Icons.store, size: 50, color: AppColors.vendorColor)),
            SizedBox(height: 14),
            Text(user.restaurantName ?? user.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            if (user.restaurantRating != null && user.restaurantRating! > 0)
              RatingStars(rating: user.restaurantRating!, size: 20),
            SizedBox(height: 4),
            Text(user.email, style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 20),

            // Stats
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _stat('Orders', '$orderCount'),
              _stat('Rating', '${user.restaurantRating ?? 0}'),
              _stat('Status', user.isApproved == true ? 'Approved' : 'Pending'),
            ]),
            SizedBox(height: 24),

            _InfoTile(Icons.person, 'Owner Name', user.name),
            _InfoTile(Icons.email, 'Email', user.email),
            _InfoTile(Icons.phone, 'Phone', user.phone),
            _InfoTile(Icons.store, 'Restaurant', user.restaurantName ?? 'N/A'),
            _InfoTile(Icons.description, 'Description',
                user.restaurantDescription ?? 'N/A'),
            _InfoTile(Icons.calendar_today, 'Joined',
                '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
            SizedBox(height: 16),

            CustomButton(
                text: 'Edit Profile',
                isOutlined: true,
                color: AppColors.vendorColor,
                onPressed: () => _showEditDialog(context, auth)),
            SizedBox(height: 12),
            CustomButton(
                text: 'Logout',
                color: AppColors.error,
                icon: Icons.logout,
                onPressed: () {
                  auth.logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/role-selection', (_) => false);
                }),
          ]),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(children: [
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 2),
        Text(label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ]);

  Widget _InfoTile(IconData icon, String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: AppColors.vendorColor, size: 22),
        SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ])),
      ]),
    );
  }

  void _showEditDialog(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final restNameCtrl = TextEditingController(text: user.restaurantName ?? '');
    final restDescCtrl =
        TextEditingController(text: user.restaurantDescription ?? '');

    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Edit Profile'),
              content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                CustomTextField(
                    hint: 'Owner Name',
                    controller: nameCtrl,
                    prefixIcon: Icons.person),
                SizedBox(height: 12),
                CustomTextField(
                    hint: 'Phone',
                    controller: phoneCtrl,
                    prefixIcon: Icons.phone),
                SizedBox(height: 12),
                CustomTextField(
                    hint: 'Restaurant Name',
                    controller: restNameCtrl,
                    prefixIcon: Icons.store),
                SizedBox(height: 12),
                CustomTextField(
                    hint: 'Description',
                    controller: restDescCtrl,
                    prefixIcon: Icons.description,
                    maxLines: 3),
              ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c), child: Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vendorColor),
                  onPressed: () {
                    auth.updateProfile(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        restaurantName: restNameCtrl.text.trim(),
                        restaurantDescription: restDescCtrl.text.trim());
                    Navigator.pop(c);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Profile updated!'),
                        backgroundColor: AppColors.success));
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            ));
  }
}
