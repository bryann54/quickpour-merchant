class ProductModel {
  final String id;
  final String productName;
  final List<String> imageUrls;
  final double price;
  final String brand;
  final String description;
  final String category;
  final int stockQuantity; // Track available inventory
  final bool isAvailable; // Product availability status
  final double discountPrice; // Sale or discounted price
  final String sku; // Stock keeping unit
  final List<String> tags; // Search tags/keywords
  final DateTime createdAt; // When product was first added
  final DateTime updatedAt; // Last modification date
 

  ProductModel({
    required this.id,
    required this.productName,
    required this.imageUrls,
    required this.price,
    required this.brand,
    required this.description,
    required this.category,
    required this.stockQuantity,
  
    this.isAvailable = true,
    this.discountPrice = 0.0,
    required this.sku,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,

  });

  // Optional: Add a method to check if product is on sale
  bool get isOnSale => discountPrice > 0 && discountPrice < price;

  // Optional: Add a method to get current selling price
  double get sellingPrice => discountPrice > 0 ? discountPrice : price;

  // Optional: Add a method to check if product is in stock
  bool get inStock => stockQuantity > 0;

}
