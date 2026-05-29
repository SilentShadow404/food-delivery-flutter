import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/order_provider.dart';
import 'package:zomato/widgets/custom_button.dart';
import 'package:zomato/widgets/custom_text_field.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    // If not logged in, show login prompt
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Not logged in', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final orderCount =
        context.watch<OrderProvider>().getCustomerOrders(user.id).length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            SizedBox(height: 10),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: AssetImage(user.profileImage),
            ),
            SizedBox(height: 14),
            Text(user.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(user.email, style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 20),

            // Stats row
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _StatItem(label: 'Orders', value: '$orderCount'),
              _StatItem(label: 'Phone', value: user.phone),
            ]),
            SizedBox(height: 24),

            // Info cards
            _InfoTile(icon: Icons.person, title: 'Full Name', value: user.name),
            _InfoTile(icon: Icons.email, title: 'Email', value: user.email),
            _InfoTile(icon: Icons.phone, title: 'Phone', value: user.phone),
            _InfoTile(
                icon: Icons.location_on,
                title: 'Address',
                value: user.address.isEmpty ? 'Not set' : user.address),
            _InfoTile(
                icon: Icons.calendar_today,
                title: 'Member Since',
                value:
                    '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
            SizedBox(height: 16),

            CustomButton(
              text: 'Edit Profile',
              isOutlined: true,
              color: AppColors.primary,
              onPressed: () => _showEditDialog(context, auth),
            ),
            SizedBox(height: 12),
            CustomButton(
              text: 'Logout',
              color: AppColors.error,
              icon: Icons.logout,
              onPressed: () {
                auth.logout();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/role-selection', (_) => false);
              },
            ),
          ]),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.currentUser!.name);
    final phoneCtrl = TextEditingController(text: auth.currentUser!.phone);
    final addressCtrl = TextEditingController(text: auth.currentUser!.address);

    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Edit Profile'),
              content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                CustomTextField(
                    hint: 'Name',
                    controller: nameCtrl,
                    prefixIcon: Icons.person),
                SizedBox(height: 12),
                CustomTextField(
                    hint: 'Phone',
                    controller: phoneCtrl,
                    prefixIcon: Icons.phone),
                SizedBox(height: 12),
                CustomTextField(
                    hint: 'Address',
                    controller: addressCtrl,
                    prefixIcon: Icons.location_on,
                    maxLines: 2),
              ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c), child: Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  onPressed: () {
                    auth.updateProfile(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        address: addressCtrl.text.trim());
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

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      SizedBox(height: 2),
      Text(label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    ]);
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title, value;
  const _InfoTile(
      {required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 22),
        SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}
