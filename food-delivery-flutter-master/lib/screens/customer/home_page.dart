import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/food_item_model.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/food_provider.dart';
import 'package:zomato/providers/cart_provider.dart';
import 'package:zomato/screens/customer/food_detail_screen.dart';
import 'package:zomato/services/logger_service.dart';
import 'package:zomato/widgets/food_card_widget.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String _selectedCategory = 'All';

  // AdMob banner ad
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  // AdMob test banner unit ID
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          log.info('[Ads] Banner ad loaded');
          if (mounted) setState(() => _bannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          log.warning('[Ads] Banner failed: ${error.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final foodProv = context.watch<FoodProvider>();
    final cart = context.read<CartProvider>();
    final user = auth.currentUser;
    final foods = foodProv.getFoodsByCategory(_selectedCategory);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                children: [
                  // Greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Hello, ${user?.name.split(' ').first ?? 'User'} 👋',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            const Text('What would you\nlike to eat?',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3)),
                          ]),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.notifications_outlined,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // MealDB-powered Categories
                  const Text('Categories',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: foodProv.categories.length,
                      itemBuilder: (ctx, i) {
                        final cat = foodProv.categories[i];
                        final isSelected = cat == _selectedCategory;
                        final imgUrl = foodProv.categoryImages[cat];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.divider),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Network image from TheMealDB API
                                if (cat != 'All' && imgUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      imgUrl,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                          Icons.restaurant,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.primary,
                                          size: 30),
                                    ),
                                  )
                                else
                                  Icon(Icons.restaurant,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.primary,
                                      size: 30),
                                const SizedBox(height: 6),
                                Text(cat,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Special offers slider
                  if (_selectedCategory == 'All' &&
                      foodProv.discountedFoods.isNotEmpty) ...[
                    _sectionHeader('Special Offers 🔥'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: foodProv.discountedFoods.length,
                        itemBuilder: (ctx, i) => _buildHorizontalCard(
                            foodProv.discountedFoods[i], cart),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Food list
                  _sectionHeader(_selectedCategory == 'All'
                      ? 'All Food Items'
                      : _selectedCategory),
                  const SizedBox(height: 12),
                  if (foods.isEmpty)
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Text('No items in this category',
                                style:
                                    TextStyle(color: AppColors.textSecondary))))
                  else
                    ...foods.map((f) => FoodCardWidget(
                          food: f,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => FoodDetailScreen(food: f))),
                          onAddToCart: () {
                            cart.addItem(f);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${f.name} added to cart'),
                                duration: const Duration(seconds: 1)));
                          },
                        )),
                ],
              ),
            ),

            // AdMob Banner Ad at bottom
            if (_bannerLoaded && _bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHorizontalCard(FoodItem food, CartProvider cart) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food))),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(food.imagePath,
                    height: 120, width: 200, fit: BoxFit.cover)),
            Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('${food.discount.toInt()}% OFF',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                )),
          ]),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(food.vendorName,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('Rs ${food.discountedPrice.toInt()}',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      Text('Rs ${food.price.toInt()}',
                          style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 12)),
                    ]),
                  ])),
        ]),
      ),
    );
  }
}
