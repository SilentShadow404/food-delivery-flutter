import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/cart_provider.dart';
import 'package:zomato/providers/order_provider.dart';
import 'package:zomato/services/encryption_service.dart';
import 'package:zomato/services/logger_service.dart';
import 'package:zomato/widgets/custom_button.dart';
import 'package:zomato/widgets/custom_text_field.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';
  final _payments = [
    'Cash on Delivery',
    'Credit Card',
    'Debit Card',
    'JazzCash',
    'EasyPaisa'
  ];

  // AdMob interstitial ad
  InterstitialAd? _interstitialAd;
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    // Decrypt stored address before populating the field
    final rawAddress = user?.address ?? '';
    _addressCtrl.text = crypto.decryptSafe(rawAddress);
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          log.info('[Ads] Interstitial loaded');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          log.warning('[Ads] Interstitial failed: ${error.message}');
        },
      ),
    );
  }

  void _showInterstitialAndNavigate() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (mounted) Navigator.pop(context);
        },
        onAdFailedToShowFullScreenContent: (ad, _) {
          ad.dispose();
          if (mounted) Navigator.pop(context);
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Checkout'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Order summary
          Text('Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ...cart.items.map((item) => Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(item.food.imagePath,
                          width: 50, height: 50, fit: BoxFit.cover)),
                  SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(item.food.name,
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                            '${item.quantity} x Rs ${item.food.discountedPrice.toInt()}',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ])),
                  Text('Rs ${item.totalPrice.toInt()}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
              )),
          SizedBox(height: 20),

          // Delivery address
          Text('Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          CustomTextField(
              hint: 'Enter delivery address',
              controller: _addressCtrl,
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2),
          SizedBox(height: 20),

          // Payment method
          Text('Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ..._payments.map((method) => RadioListTile<String>(
                title: Text(method),
                value: method,
                groupValue: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v!),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                tileColor: _paymentMethod == method
                    ? AppColors.primaryLight.withAlpha(80)
                    : null,
              )),
          SizedBox(height: 20),

          // Price breakdown
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _row('Subtotal', 'Rs ${cart.subtotal.toInt()}'),
              _row('Tax (5%)', 'Rs ${cart.tax.toInt()}'),
              _row('Delivery Fee', 'Rs ${cart.deliveryFee.toInt()}'),
              Divider(height: 20),
              _row('Total', 'Rs ${cart.total.toInt()}', bold: true),
            ]),
          ),
          SizedBox(height: 24),

          CustomButton(
            text: 'Place Order',
            icon: Icons.check_circle,
            onPressed: () {
              if (_addressCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter delivery address'),
                    backgroundColor: AppColors.error));
                return;
              }
              final orders = context.read<OrderProvider>();

              // Encrypt the delivery address before storing / transmitting
              final plainAddress = _addressCtrl.text.trim();
              final encryptedAddress = crypto.encrypt(plainAddress);
              log.info('[Checkout] Address encrypted for order storage');

              // Group items by vendor
              final vendorGroups = <String, List<dynamic>>{};
              for (final item in cart.items) {
                vendorGroups
                    .putIfAbsent(item.food.vendorId, () => [])
                    .add(item);
              }
              // Create one order per vendor
              for (final entry in vendorGroups.entries) {
                final vendorItems = entry.value;
                final sub = vendorItems.fold(
                    0.0, (double sum, item) => sum + item.totalPrice);
                orders.placeOrder(
                  customerId: auth.currentUser!.id,
                  customerName: auth.currentUser!.name,
                  customerPhone: auth.currentUser!.phone,
                  vendorId: entry.key,
                  vendorName: vendorItems.first.food.vendorName,
                  items: List.from(vendorItems),
                  subtotal: sub,
                  tax: sub * 0.05,
                  deliveryFee: 50,
                  total: sub + sub * 0.05 + 50,
                  // Store encrypted address; decrypt when displaying
                  deliveryAddress: encryptedAddress,
                  paymentMethod: _paymentMethod,
                );
              }
              cart.clear();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Order placed successfully! 🎉'),
                  backgroundColor: AppColors.success));
              // Show interstitial ad then navigate back
              _showInterstitialAndNavigate();
            },
          ),
        ]),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                color: bold ? null : AppColors.textSecondary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 17 : 14)),
        Text(value,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                fontSize: bold ? 17 : 14,
                color: bold ? AppColors.primary : null)),
      ]),
    );
  }
}
