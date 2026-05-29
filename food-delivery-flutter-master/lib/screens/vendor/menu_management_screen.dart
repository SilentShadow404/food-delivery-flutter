import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/food_provider.dart';
import 'package:zomato/screens/vendor/add_edit_food_screen.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final foodProv = context.watch<FoodProvider>();
    final vendorId = auth.currentUser!.id;
    final items = foodProv.getFoodsByVendor(vendorId);

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
                    Text('Menu Management',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('${items.length} items',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ]),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(Icons.restaurant_menu,
                              size: 80, color: Colors.grey[300]),
                          SizedBox(height: 16),
                          Text('No menu items yet',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary)),
                        ]))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) {
                        final food = items[i];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 1))
                              ]),
                          child: Row(children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(food.imagePath,
                                    width: 70, height: 70, fit: BoxFit.cover)),
                            SizedBox(width: 14),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(food.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  SizedBox(height: 2),
                                  Text(food.category,
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                  SizedBox(height: 4),
                                  Row(children: [
                                    Text('Rs ${food.price.toInt()}',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold)),
                                    if (food.discount > 0)
                                      Text('  ${food.discount.toInt()}% off',
                                          style: TextStyle(
                                              color: AppColors.error,
                                              fontSize: 12)),
                                  ]),
                                ])),
                            Column(children: [
                              // Availability toggle
                              Switch(
                                value: food.isAvailable,
                                activeTrackColor: AppColors.success,
                                onChanged: (_) =>
                                    foodProv.toggleAvailability(food.id),
                              ),
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(
                                    icon: Icon(Icons.edit,
                                        color: AppColors.vendorColor, size: 20),
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => AddEditFoodScreen(
                                                food: food)))),
                                IconButton(
                                    icon: Icon(Icons.delete,
                                        color: AppColors.error, size: 20),
                                    onPressed: () => _confirmDelete(
                                        context, foodProv, food.id, food.name)),
                              ]),
                            ]),
                          ]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => AddEditFoodScreen())),
        backgroundColor: AppColors.vendorColor,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Item', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, FoodProvider prov, String id, String name) {
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Delete Item'),
              content: Text('Are you sure you want to delete "$name"?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c), child: Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error),
                  onPressed: () {
                    prov.deleteFood(id);
                    Navigator.pop(c);
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            ));
  }
}
