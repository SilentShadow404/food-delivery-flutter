import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/providers/cart_provider.dart';
import 'package:zomato/screens/customer/checkout_screen.dart';
import 'package:zomato/widgets/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Cart',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    if (cart.items.isNotEmpty)
                      TextButton(
                        onPressed: () => _showClearDialog(context, cart),
                        child: Text('Clear All',
                            style: TextStyle(color: AppColors.error)),
                      ),
                  ]),
            ),
            Expanded(
              child: cart.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 80, color: Colors.grey[300]),
                          SizedBox(height: 16),
                          Text('Your cart is empty',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary)),
                          SizedBox(height: 8),
                          Text('Add some delicious food!',
                              style: TextStyle(color: AppColors.textHint)),
                        ]))
                  : ListView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: cart.items.length,
                      itemBuilder: (ctx, i) {
                        final item = cart.items[i];
                        return Container(
                          margin: EdgeInsets.only(bottom: 14),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withAlpha(15),
                                    blurRadius: 6,
                                    offset: Offset(0, 2))
                              ]),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(item.food.imagePath,
                                  width: 70, height: 70, fit: BoxFit.cover),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(item.food.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  SizedBox(height: 2),
                                  Text(item.food.vendorName,
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                  SizedBox(height: 4),
                                  Text('Rs ${item.totalPrice.toInt()}',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                ])),
                            Column(children: [
                              GestureDetector(
                                onTap: () => cart.removeItem(item.food.id),
                                child: Icon(Icons.delete_outline,
                                    color: AppColors.error, size: 20),
                              ),
                              SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _qtyBtn(Icons.remove,
                                          () => cart.decreaseQty(item.food.id)),
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text('${item.quantity}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16))),
                                      _qtyBtn(Icons.add,
                                          () => cart.increaseQty(item.food.id)),
                                    ]),
                              ),
                            ]),
                          ]),
                        );
                      },
                    ),
            ),
            // Bottom summary
            if (cart.items.isNotEmpty)
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2))
                    ]),
                child: Column(children: [
                  _summaryRow('Subtotal', 'Rs ${cart.subtotal.toInt()}'),
                  _summaryRow('Tax (5%)', 'Rs ${cart.tax.toInt()}'),
                  _summaryRow('Delivery Fee', 'Rs ${cart.deliveryFee.toInt()}'),
                  Divider(height: 20),
                  _summaryRow('Total', 'Rs ${cart.total.toInt()}', bold: true),
                  SizedBox(height: 16),
                  CustomButton(
                    text: 'Proceed to Checkout',
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => CheckoutScreen())),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 18 : 14)),
        Text(value,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                fontSize: bold ? 18 : 14,
                color: bold ? AppColors.primary : AppColors.textPrimary)),
      ]),
    );
  }

  void _showClearDialog(BuildContext context, CartProvider cart) {
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Clear Cart'),
              content: Text('Remove all items from your cart?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c), child: Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error),
                  onPressed: () {
                    cart.clear();
                    Navigator.pop(c);
                  },
                  child: Text('Clear', style: TextStyle(color: Colors.white)),
                ),
              ],
            ));
  }
}
