import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current merchant ID
  String get currentMerchantId => _auth.currentUser?.uid ?? '';
  Stream<List<MerchantProductModel>> streamMerchantProducts() {
    if (currentMerchantId.isEmpty) {
      throw Exception('No authenticated merchant found');
    }

    return _firestore
        .collection('products')
        .where('merchantId', isEqualTo: currentMerchantId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MerchantProductModel.fromMap(doc.data()))
            .toList());
  }

  // Add a product
  Future<void> addProduct(MerchantProductModel product) async {
    // Ensure the product has the current merchant's ID
    final productWithMerchantId = MerchantProductModel(
      id: product.id,
      merchantId: currentMerchantId,
      productName: product.productName,
      imageUrls: product.imageUrls,
      price: product.price,
      brandName: product.brandName,
      description: product.description,
      categoryName: product.categoryName,
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
  Future<List<MerchantProductModel>> fetchProducts() async {
    final snapshot = await _firestore
        .collection('products')
        .where('merchantId', isEqualTo: currentMerchantId)
        .get();

    return snapshot.docs
        .map((doc) => MerchantProductModel.fromMap(doc.data()))
        .toList();
  }

  Future<int> fetchStockCount() async {
    final products = await fetchProducts();
    return products.fold(0, (sum, product) => product.stockQuantity);
  }

  // Update a product
  Future<void> updateProduct(MerchantProductModel product) async {
    // Verify the product belongs to the current merchant
    final productDoc =
        await _firestore.collection('products').doc(product.id).get();

    if (productDoc.exists) {
      final existingProduct = MerchantProductModel.fromMap(productDoc.data()!);
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
      final product = MerchantProductModel.fromMap(productDoc.data()!);
      if (product.merchantId != currentMerchantId) {
        throw Exception('Unauthorized to delete this product');
      }
    }

    await _firestore.collection('products').doc(productId).delete();
  }

  // Optional: Fetch a single product
  Future<MerchantProductModel?> fetchProduct(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();

    if (!doc.exists) return null;

    final product = MerchantProductModel.fromMap(doc.data()!);

    // Verify the product belongs to the current merchant
    if (product.merchantId != currentMerchantId) {
      throw Exception('Unauthorized to access this product');
    }

    return product;
  }
}
