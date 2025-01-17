import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantProductModel {
  final String id;
  final String productName;
  final List<String> imageUrls;
  final double price;
  final String merchantId;
  final String brandName;
  final String description;
  final String categoryName;
  final int stockQuantity;
  final bool isAvailable;
  final double discountPrice;
  final String sku;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantProductModel({
    required this.id,
    required this.productName,
    required this.imageUrls,
    required this.price,
    required this.merchantId,
    required this.brandName,
    required this.description,
    required this.categoryName,
    required this.stockQuantity,
    this.isAvailable = true,
    this.discountPrice = 0.0,
    required this.sku,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantProductModel.fromMap(Map<String, dynamic> map) {
    return MerchantProductModel(
      id: map['id'] ?? '',
      productName: map['productName'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      price: (map['price'] ?? 0.0).toDouble(),
      merchantId: map['merchantId'] ?? '',
      brandName: map['brandName'] ?? '',
      description: map['description'] ?? '',
      categoryName: map['categoryName'] ?? '',
      stockQuantity: map['stockQuantity'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      discountPrice: (map['discountPrice'] ?? 0.0).toDouble(),
      sku: map['sku'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'imageUrls': imageUrls,
      'price': price,
      'merchantId': merchantId,
      'brandName': brandName,
      'description': description,
      'categoryName': categoryName,
      'stockQuantity': stockQuantity,
      'isAvailable': isAvailable,
      'discountPrice': discountPrice,
      'sku': sku,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
