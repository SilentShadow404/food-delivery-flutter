class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String foodId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.foodId,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'foodId': foodId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ReviewModel.fromMap(Map<String, dynamic> m) {
    return ReviewModel(
      id: m['id']?.toString() ?? '',
      userId: m['userId']?.toString() ?? '',
      userName: m['userName']?.toString() ?? '',
      foodId: m['foodId']?.toString() ?? '',
      rating: (m['rating'] is num) ? (m['rating'] as num).toDouble() : 0.0,
      comment: m['comment']?.toString() ?? '',
      createdAt: m['createdAt'] != null
          ? DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
