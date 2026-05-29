import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/widgets/custom_button.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            SizedBox(height: 20),
            CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.adminColor.withAlpha(30),
                child: Icon(Icons.admin_panel_settings,
                    size: 50, color: AppColors.adminColor)),
            SizedBox(height: 14),
            Text(user.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.adminColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Administrator',
                  style: TextStyle(
                      color: AppColors.adminColor,
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 4),
            Text(user.email, style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 24),

            // System Info
            _SectionTitle('System Statistics'),
            SizedBox(height: 8),
            Row(children: [
              _MiniStat('Customers', '${auth.customers.length}', Icons.people,
                  AppColors.vendorColor),
              SizedBox(width: 10),
              _MiniStat('Vendors', '${auth.approvedVendors.length}',
                  Icons.store, AppColors.primary),
              SizedBox(width: 10),
              _MiniStat('Pending', '${auth.pendingVendors.length}',
                  Icons.pending, AppColors.warning),
            ]),
            SizedBox(height: 24),

            _SectionTitle('Account Information'),
            SizedBox(height: 8),
            _InfoTile(Icons.person, 'Name', user.name),
            _InfoTile(Icons.email, 'Email', user.email),
            _InfoTile(Icons.phone, 'Phone', user.phone),
            _InfoTile(Icons.calendar_today, 'Joined',
                '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
            SizedBox(height: 30),

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
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _MiniStat(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: color, size: 26),
        SizedBox(height: 6),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ]),
    ));
  }
}

Widget _InfoTile(IconData icon, String title, String value) {
  return Container(
    margin: EdgeInsets.only(bottom: 10),
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(icon, color: AppColors.adminColor, size: 22),
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
