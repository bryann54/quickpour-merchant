import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthRepository _authRepository = AuthRepository();
  final int _pageSize = 10; // Number of products per page
  DocumentSnapshot? _lastDocument; // Tracks the last document retrieved
  bool _hasMoreData = true; // Flag to check if more data is available

  String get currentMerchantId => _auth.currentUser?.uid ?? '';

  // Add a product with auto-populated merchant details
  Future<void> addProduct(MerchantProductModel product) async {
    // Fetch current merchant details
    final merchantDetails = await _authRepository.getCurrentUserDetails();
    if (merchantDetails == null) {
      throw Exception('Could not fetch merchant details');
    }

    // Create product with auto-populated merchant details
    final productWithMerchantDetails = MerchantProductModel(
      id: product.id,
      merchantId: currentMerchantId,
      productName: product.productName,
      imageUrls: product.imageUrls,
      price: product.price,
      measure: product.measure,
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
      // Auto-populated merchant details
      merchantName: merchantDetails.name,
      merchantEmail: merchantDetails.email,
      merchantLocation: merchantDetails.location,
      merchantStoreName: merchantDetails.storeName,
      merchantImageUrl: merchantDetails.imageUrl,
      merchantRating: merchantDetails.rating,
      isMerchantVerified: merchantDetails.isVerified,
      isMerchantOpen: merchantDetails.isOpen,
    );

    await _firestore
        .collection('products')
        .doc(product.id)
        .set(productWithMerchantDetails.toMap());
  }

  // Update stream to include merchant details
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

  // Get next page of products
  Future<List<MerchantProductModel>> getNextProductsPage() async {
    if (!_hasMoreData || _lastDocument == null) {
      return [];
    }

    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .orderBy('createdAt',
              descending: true) // Use same ordering as initial query
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();

      // Update pagination state
      if (querySnapshot.docs.isEmpty) {
        _hasMoreData = false;
        return [];
      }

      _lastDocument = querySnapshot.docs.last;

      return querySnapshot.docs.map((doc) {
        return MerchantProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching next page of products: $e');
    }
  }

  // Check if more data is available
  bool hasMoreData() {
    return _hasMoreData;
  }

  // Add method for recommended products with pagination support
  Future<List<MerchantProductModel>> getRecommendedProducts(
      {int limit = 10}) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        return MerchantProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching recommended products: $e');
    }
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
