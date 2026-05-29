class FoodItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imagePath;
  final double price;
  final double discount;
  final double rating;
  final int reviewCount;
  final String vendorId;
  final String vendorName;
  final bool isAvailable;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imagePath,
    required this.price,
    this.discount = 0,
    this.rating = 0,
    this.reviewCount = 0,
    required this.vendorId,
    required this.vendorName,
    this.isAvailable = true,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? imagePath,
    double? price,
    double? discount,
    double? rating,
    int? reviewCount,
    String? vendorId,
    String? vendorName,
    bool? isAvailable,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  double get discountedPrice => price - (price * discount / 100);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'imagePath': imagePath,
        'price': price,
        'discount': discount,
        'rating': rating,
        'reviewCount': reviewCount,
        'vendorId': vendorId,
        'vendorName': vendorName,
        'isAvailable': isAvailable,
      };

  factory FoodItem.fromMap(Map<String, dynamic> m) {
    return FoodItem(
      id: m['id']?.toString() ?? '',
      name: m['name'] ?? '',
      description: m['description'] ?? '',
      category: m['category'] ?? 'All',
      imagePath: m['imagePath'] ?? 'assets/images/food.jpeg',
      price: (m['price'] is num) ? (m['price'] as num).toDouble() : 0.0,
      discount:
          (m['discount'] is num) ? (m['discount'] as num).toDouble() : 0.0,
      rating: (m['rating'] is num) ? (m['rating'] as num).toDouble() : 0.0,
      reviewCount: (m['reviewCount'] is int)
          ? m['reviewCount']
          : ((m['reviewCount'] is num) ? (m['reviewCount'] as num).toInt() : 0),
      vendorId: m['vendorId']?.toString() ?? '',
      vendorName: m['vendorName']?.toString() ?? '',
      isAvailable: m['isAvailable'] ?? true,
    );
  }
}
