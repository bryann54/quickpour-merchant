import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current merchant ID
  String get currentMerchantId => _auth.currentUser?.uid ?? '';
  Stream<List<ProductModel>> streamMerchantProducts() {
    if (currentMerchantId.isEmpty) {
      throw Exception('No authenticated merchant found');
    }

    return _firestore
        .collection('products')
        .where('merchantId', isEqualTo: currentMerchantId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .toList());
  }

  // Add a product
  Future<void> addProduct(ProductModel product) async {
    // Ensure the product has the current merchant's ID
    final productWithMerchantId = ProductModel(
      id: product.id,
      merchantId: currentMerchantId,
      productName: product.productName,
      imageUrls: product.imageUrls,
      price: product.price,
      brand: product.brand,
      description: product.description,
      category: product.category,
      stockQuantity: product.stockQuantity,
      isAvailable: product.isAvailable,
      discountPrice: product.discountPrice,
      sku: product.sku,
      tags: product.tags,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );

    await _firestore
        .collection('products')
        .doc(product.id)
        .set(productWithMerchantId.toMap());
  }

  // Fetch products for current merchant
  Future<List<ProductModel>> fetchProducts() async {
    final snapshot = await _firestore
        .collection('products')
        .where('merchantId', isEqualTo: currentMerchantId)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();
  }

  // Update a product
  Future<void> updateProduct(ProductModel product) async {
    // Verify the product belongs to the current merchant
    final productDoc =
        await _firestore.collection('products').doc(product.id).get();

    if (productDoc.exists) {
      final existingProduct = ProductModel.fromMap(productDoc.data()!);
      if (existingProduct.merchantId != currentMerchantId) {
        throw Exception('Unauthorized to update this product');
      }
    }

    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    // Verify the product belongs to the current merchant
    final productDoc =
        await _firestore.collection('products').doc(productId).get();

    if (productDoc.exists) {
      final product = ProductModel.fromMap(productDoc.data()!);
      if (product.merchantId != currentMerchantId) {
        throw Exception('Unauthorized to delete this product');
      }
    }

    await _firestore.collection('products').doc(productId).delete();
  }

  // Optional: Fetch a single product
  Future<ProductModel?> fetchProduct(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();

    if (!doc.exists) return null;

    final product = ProductModel.fromMap(doc.data()!);

    // Verify the product belongs to the current merchant
    if (product.merchantId != currentMerchantId) {
      throw Exception('Unauthorized to access this product');
    }

    return product;
  }
}
