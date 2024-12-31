class ProductModel {
  final String id;
  final String productName;
  final List<String> imageUrls;
  final double price;
  final String brand;
  final String description;
  final String category;
  final int stockQuantity;
  final bool isAvailable;
  final double discountPrice;
  final String sku;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

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

  // Convert ProductModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'imageUrls': imageUrls,
      'price': price,
      'brand': brand,
      'description': description,
      'category': category,
      'stockQuantity': stockQuantity,
      'isAvailable': isAvailable,
      'discountPrice': discountPrice,
      'sku': sku,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create ProductModel from Map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      productName: map['productName'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      price: (map['price'] ?? 0).toDouble(),
      brand: map['brand'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      stockQuantity: (map['stockQuantity'] ?? 0).toInt(),
      isAvailable: map['isAvailable'] ?? true,
      discountPrice: (map['discountPrice'] ?? 0).toDouble(),
      sku: map['sku'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
