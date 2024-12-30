
class ProductModel {
  final String id;
  final String productName;
  final List<String> imageUrls;
  final double price;
  final String brand;
  final String description;
  final String category;

  ProductModel({
    required this.brand,
    required this.id,
    required this.productName,
    required this.imageUrls,
    required this.price,
    required this.description,
    required this.category,
  });
}
