import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/food_item_model.dart';
import 'package:zomato/models/review_model.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/food_provider.dart';
import 'package:zomato/providers/cart_provider.dart';
import 'package:zomato/widgets/rating_stars.dart';
import 'package:zomato/widgets/custom_button.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem food;
  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final foodProv = context.watch<FoodProvider>();
    final reviews = foodProv.getReviewsForFood(widget.food.id);
    final inCartQty = cart.getQuantity(widget.food.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(widget.food.imagePath, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Price
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(widget.food.name,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold))),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (widget.food.discount > 0)
                                  Text('Rs ${widget.food.price.toInt()}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey)),
                                Text(
                                    'Rs ${widget.food.discountedPrice.toInt()}',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary)),
                              ]),
                        ]),
                    SizedBox(height: 8),
                    Row(children: [
                      RatingStars(rating: widget.food.rating, size: 18),
                      SizedBox(width: 8),
                      Text('(${widget.food.reviewCount} reviews)',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ]),
                    SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.store,
                          size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text(widget.food.vendorName,
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                      SizedBox(width: 12),
                      Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(widget.food.category,
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600))),
                    ]),
                    if (widget.food.discount > 0) ...[
                      SizedBox(height: 10),
                      Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppColors.error.withAlpha(20),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(children: [
                            Icon(Icons.local_offer,
                                color: AppColors.error, size: 18),
                            SizedBox(width: 8),
                            Text(
                                '${widget.food.discount.toInt()}% discount applied!',
                                style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600))
                          ])),
                    ],
                    SizedBox(height: 16),
                    Text('Description',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(widget.food.description,
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            height: 1.5)),
                    SizedBox(height: 20),

                    // Quantity selector
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _qtyButton(Icons.remove, () {
                        if (_quantity > 1) setState(() => _quantity--);
                      }),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('$_quantity',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      _qtyButton(Icons.add, () => setState(() => _quantity++)),
                    ]),
                    SizedBox(height: 16),
                    if (inCartQty > 0)
                      Center(
                          child: Text('Already $inCartQty in cart',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600))),
                    SizedBox(height: 12),
                    CustomButton(
                      text:
                          'Add to Cart  •  Rs ${(widget.food.discountedPrice * _quantity).toInt()}',
                      icon: Icons.add_shopping_cart,
                      onPressed: () {
                        for (int i = 0; i < _quantity; i++)
                          cart.addItem(widget.food);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '$_quantity x ${widget.food.name} added to cart'),
                            duration: Duration(seconds: 1)));
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 24),

                    // Reviews section
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Reviews (${reviews.length})',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            onPressed: () => _showAddReviewDialog(context),
                            icon: Icon(Icons.rate_review, size: 18),
                            label: Text('Write Review'),
                          ),
                        ]),
                    if (reviews.isEmpty)
                      Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                              child: Text('No reviews yet. Be the first!',
                                  style: TextStyle(
                                      color: AppColors.textSecondary))))
                    else
                      ...reviews.map(_buildReviewCard),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                child: Text(review.userName[0],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary))),
            SizedBox(width: 10),
            Text(review.userName,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          RatingStars(rating: review.rating, size: 14, showValue: false),
        ]),
        SizedBox(height: 8),
        Text(review.comment,
            style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
      ]),
    );
  }

  void _showAddReviewDialog(BuildContext ctx) {
    double rating = 5;
    final commentCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (c) => StatefulBuilder(builder: (c, setDialogState) {
        return AlertDialog(
          title: Text('Write a Review'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            InteractiveRating(
                rating: rating,
                onRatingChanged: (v) => setDialogState(() => rating = v)),
            SizedBox(height: 16),
            TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)))),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c), child: Text('Cancel')),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (commentCtrl.text.isEmpty) return;
                final auth = ctx.read<AuthProvider>();
                final foodProv = ctx.read<FoodProvider>();
                foodProv.addReview(ReviewModel(
                  id: foodProv.nextReviewId,
                  userId: auth.currentUser!.id,
                  userName: auth.currentUser!.name,
                  foodId: widget.food.id,
                  rating: rating,
                  comment: commentCtrl.text.trim(),
                ));
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Review submitted!'),
                    backgroundColor: AppColors.success));
              },
              child: Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }
}
