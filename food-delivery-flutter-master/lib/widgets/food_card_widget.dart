import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/food_item_model.dart';

/// Returns the correct image widget depending on whether [path] is a
/// local file-system path (picked by image_picker) or a bundled asset.
Widget _buildFoodImage(String path,
    {double height = 160, BoxFit fit = BoxFit.cover}) {
  if (path.startsWith('/') || path.startsWith('file://')) {
    final file = File(path.replaceFirst('file://', ''));
    return file.existsSync()
        ? Image.file(file, height: height, width: double.infinity, fit: fit)
        : _placeholderImage(height);
  }
  return Image.asset(path,
      height: height,
      width: double.infinity,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholderImage(height));
}

Widget _placeholderImage(double height) => Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[200],
      child: Icon(Icons.fastfood, size: 48, color: Colors.grey[400]),
    );

class FoodCardWidget extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const FoodCardWidget({
    super.key,
    required this.food,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildFoodImage(food.imagePath),
                ),
                if (food.discount > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('${food.discount.toInt()}% OFF',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (onAddToCart != null)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                        child: Icon(Icons.add, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
              ],
            ),
            // Info
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(food.name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      Row(children: [
                        Icon(Icons.star, color: AppColors.starColor, size: 16),
                        SizedBox(width: 2),
                        Text('${food.rating}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ]),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(food.vendorName,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      if (food.discount > 0) ...[
                        Text('Rs ${food.price.toInt()}',
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 13)),
                        SizedBox(width: 6),
                      ],
                      Text('Rs ${food.discountedPrice.toInt()}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
