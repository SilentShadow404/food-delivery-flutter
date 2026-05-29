import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/providers/food_provider.dart';
import 'package:zomato/providers/cart_provider.dart';
import 'package:zomato/screens/customer/food_detail_screen.dart';
import 'package:zomato/widgets/food_card_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foodProv = context.watch<FoodProvider>();
    final cart = context.read<CartProvider>();
    final results =
        _query.isEmpty ? foodProv.popularFoods : foodProv.searchFoods(_query);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search Food',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search food, restaurant, category...',
                        prefixIcon:
                            Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                })
                            : null,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                        _query.isEmpty
                            ? 'Popular Items'
                            : '${results.length} results found',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                  ]),
            ),
            SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(Icons.search_off,
                              size: 60, color: Colors.grey[300]),
                          SizedBox(height: 12),
                          Text('No results found',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16)),
                        ]))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: results.length,
                      itemBuilder: (ctx, i) => FoodCardWidget(
                        food: results[i],
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    FoodDetailScreen(food: results[i]))),
                        onAddToCart: () {
                          cart.addItem(results[i]);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${results[i].name} added to cart'),
                              duration: Duration(seconds: 1)));
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
