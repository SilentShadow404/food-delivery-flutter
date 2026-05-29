import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/user_model.dart';
import 'package:zomato/providers/auth_provider.dart';

class VendorManagementScreen extends StatefulWidget {
  const VendorManagementScreen({super.key});

  @override
  State<VendorManagementScreen> createState() => _VendorManagementScreenState();
}

class _VendorManagementScreenState extends State<VendorManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text('Vendor Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          TabBar(
              controller: _tabCtrl,
              labelColor: AppColors.adminColor,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.adminColor,
              tabs: [
                Tab(text: 'Pending (${auth.pendingVendors.length})'),
                Tab(text: 'Approved (${auth.approvedVendors.length})'),
              ]),
          Expanded(
            child: TabBarView(controller: _tabCtrl, children: [
              _VendorList(vendors: auth.pendingVendors, isPending: true),
              _VendorList(vendors: auth.approvedVendors, isPending: false),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _VendorList extends StatelessWidget {
  final List<UserModel> vendors;
  final bool isPending;
  const _VendorList({required this.vendors, required this.isPending});

  @override
  Widget build(BuildContext context) {
    if (vendors.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(isPending ? Icons.hourglass_empty : Icons.check_circle,
            size: 60, color: Colors.grey[300]),
        SizedBox(height: 10),
        Text(isPending ? 'No pending vendors' : 'No approved vendors',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
      ]));
    }
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: vendors.length,
      itemBuilder: (ctx, i) =>
          _VendorCard(vendor: vendors[i], isPending: isPending),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final UserModel vendor;
  final bool isPending;
  const _VendorCard({required this.vendor, required this.isPending});

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
        Row(children: [
          CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withAlpha(20),
              child: Icon(Icons.store, color: AppColors.primary)),
          SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(vendor.restaurantName ?? vendor.name,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(vendor.email,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ])),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isPending
                      ? AppColors.warning
                      : vendor.isActive
                          ? AppColors.success
                          : AppColors.error)
                  .withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
                isPending
                    ? 'Pending'
                    : vendor.isActive
                        ? 'Active'
                        : 'Inactive',
                style: TextStyle(
                    color: isPending
                        ? AppColors.warning
                        : vendor.isActive
                            ? AppColors.success
                            : AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ),
        ]),
        SizedBox(height: 10),
        if (vendor.restaurantDescription != null &&
            vendor.restaurantDescription!.isNotEmpty)
          Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(vendor.restaurantDescription!,
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        Row(children: [
          Icon(Icons.person, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 4),
          Text('Owner: ${vendor.name}',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          SizedBox(width: 16),
          Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 4),
          Text(vendor.phone,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ]),
        SizedBox(height: 12),
        if (isPending)
          Row(children: [
            Expanded(
                child: OutlinedButton(
              onPressed: () {
                context.read<AuthProvider>().rejectVendor(vendor.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        '${vendor.restaurantName ?? vendor.name} rejected'),
                    backgroundColor: AppColors.error));
              },
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              child: Text('Reject'),
            )),
            SizedBox(width: 10),
            Expanded(
                child: ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().approveVendor(vendor.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        '${vendor.restaurantName ?? vendor.name} approved!'),
                    backgroundColor: AppColors.success));
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              child: Text('Approve', style: TextStyle(color: Colors.white)),
            )),
          ])
        else
          SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<AuthProvider>().toggleUserActive(vendor.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(vendor.isActive
                          ? '${vendor.restaurantName ?? vendor.name} deactivated'
                          : '${vendor.restaurantName ?? vendor.name} activated')));
                },
                style: OutlinedButton.styleFrom(
                    foregroundColor:
                        vendor.isActive ? AppColors.error : AppColors.success),
                child: Text(
                    vendor.isActive ? 'Deactivate Vendor' : 'Activate Vendor'),
              )),
      ]),
    );
  }
}
