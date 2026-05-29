import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/user_model.dart';
import 'package:zomato/providers/auth_provider.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final customers = auth.customers;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('User Management',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.adminColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('${customers.length} users',
                          style: TextStyle(
                              color: AppColors.adminColor,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
            ),
            Expanded(
              child: customers.isEmpty
                  ? Center(
                      child: Text('No customers registered yet',
                          style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: customers.length,
                      itemBuilder: (ctx, i) => _UserCard(user: customers[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))
          ]),
      child: Row(children: [
        CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.vendorColor.withAlpha(30),
            child: Text(user.name[0].toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.vendorColor,
                    fontSize: 20))),
        SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 2),
          Text(user.email,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(user.phone,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ])),
        Column(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (user.isActive ? AppColors.success : AppColors.error)
                  .withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(user.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                    color: user.isActive ? AppColors.success : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              context.read<AuthProvider>().toggleUserActive(user.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(user.isActive
                      ? '${user.name} deactivated'
                      : '${user.name} activated')));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (user.isActive ? AppColors.error : AppColors.success)
                    .withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(user.isActive ? 'Deactivate' : 'Activate',
                  style: TextStyle(
                      color:
                          user.isActive ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ),
          ),
        ]),
      ]),
    );
  }
}
