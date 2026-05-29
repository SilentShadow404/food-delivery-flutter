class FoodData {
  final String id;
  final String name;
  final String category;
  final String imagePath;
  final double price;
  final double discount;
  final double ratings;

  FoodData(
      {required this.id,
      required this.name,
      required this.category,
      required this.imagePath,
      required this.discount,
      required this.price,
      required this.ratings});
}
