import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickpourmerchant/features/promotions/data/models/promotion_model.dart';

class PromotionsRepository {
  final FirebaseFirestore _firestore;

  PromotionsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _promotionsCollection =>
      _firestore.collection('promotions');

  // Fetch all promotions for a merchant
  Future<List<MerchantPromotionModel>> fetchMerchantPromotions(
      String merchantId) async {
    try {
      final querySnapshot = await _promotionsCollection
          .where('merchantId', isEqualTo: merchantId)
          .where('status', isNotEqualTo: PromotionStatus.deleted.toString())
          .get();

      return querySnapshot.docs
          .map((doc) => MerchantPromotionModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error fetching merchant promotions: ${e.toString()}');
      throw Exception('Failed to fetch merchant promotions: $e');
    }
  }

  // Fetch only active promotions for a merchant
  Future<List<MerchantPromotionModel>> fetchActiveMerchantPromotions(
      String merchantId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _promotionsCollection
          .where('merchantId', isEqualTo: merchantId)
          .where('isActive', isEqualTo: true)
          .where('status', isEqualTo: PromotionStatus.active.toString())
          .where('startDate', isLessThanOrEqualTo: now.toIso8601String())
          .where('endDate', isGreaterThanOrEqualTo: now.toIso8601String())
          .get();

      return querySnapshot.docs
          .map((doc) => MerchantPromotionModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active merchant promotions: $e');
    }
  }

  // Fetch promotions applicable to specific products
  Future<List<MerchantPromotionModel>> fetchPromotionsForProducts(
      String merchantId, List<String> productIds) async {
    try {
      final now = DateTime.now();
      // Need to handle this differently since we can't do a where-in query on arrays
      final allActivePromotions = await _promotionsCollection
          .where('merchantId', isEqualTo: merchantId)
          .where('isActive', isEqualTo: true)
          .where('status', isEqualTo: PromotionStatus.active.toString())
          .where('startDate', isLessThanOrEqualTo: now.toIso8601String())
          .where('endDate', isGreaterThanOrEqualTo: now.toIso8601String())
          .get();

      // Filter manually for product/category/brand matches
      List<MerchantPromotionModel> applicablePromotions = [];

      for (var doc in allActivePromotions.docs) {
        final promotion = MerchantPromotionModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });

        // For product target promotions
        if (promotion.promotionTarget == PromotionTarget.products) {
          if (promotion.productIds.any((id) => productIds.contains(id))) {
            applicablePromotions.add(promotion);
            continue;
          }
        }

        // For category/brand promotions, we would need the product details
        // to check if they belong to the relevant categories/brands
        // This simplification assumes we just want product-targeted promotions
      }

      return applicablePromotions;
    } catch (e) {
      throw Exception('Failed to fetch promotions for products: $e');
    }
  }

  // Create a new promotion
  Future<void> createPromotion(MerchantPromotionModel promotion) async {
    try {
      await _promotionsCollection.doc(promotion.id).set(promotion.toJson());
    } catch (e) {
      throw Exception('Failed to create promotion: $e');
    }
  }

  // Update an existing promotion
  Future<void> updatePromotion(MerchantPromotionModel promotion) async {
    try {
      await _promotionsCollection.doc(promotion.id).update(promotion.toJson());
    } catch (e) {
      throw Exception('Failed to update promotion: $e');
    }
  }

  // Soft delete a promotion
  Future<void> softDeletePromotion(String promotionId) async {
    try {
      await _promotionsCollection.doc(promotionId).update({
        'status': PromotionStatus.deleted.toString(),
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to delete promotion: $e');
    }
  }

  // Increment usage count for a promotion
  Future<void> incrementPromotionUsage(String promotionId) async {
    try {
      // Get current promotion to check usage limit
      final doc = await _promotionsCollection.doc(promotionId).get();
      if (!doc.exists) {
        throw Exception('Promotion not found');
      }

      final promotion = MerchantPromotionModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });

      // Check if usage limit is reached
      if (promotion.usageLimit != null &&
          promotion.usageCount >= promotion.usageLimit!) {
        throw Exception('Promotion usage limit reached');
      }

      // Increment usage count
      await _promotionsCollection.doc(promotionId).update({
        'usageCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment promotion usage: $e');
    }
  }
}
