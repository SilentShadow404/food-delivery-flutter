import 'package:flutter/material.dart';
import 'package:zomato/constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool showValue;

  const RatingStars(
      {super.key, required this.rating, this.size = 18, this.showValue = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return Icon(Icons.star, color: AppColors.starColor, size: size);
          } else if (i < rating) {
            return Icon(Icons.star_half,
                color: AppColors.starColor, size: size);
          }
          return Icon(Icons.star_border,
              color: AppColors.starColor, size: size);
        }),
        if (showValue) ...[
          SizedBox(width: 4),
          Text('$rating',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: size * 0.75)),
        ],
      ],
    );
  }
}

class InteractiveRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final double size;

  const InteractiveRating(
      {super.key,
      required this.rating,
      required this.onRatingChanged,
      this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () => onRatingChanged(i + 1.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              i < rating ? Icons.star : Icons.star_border,
              color: AppColors.starColor,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
