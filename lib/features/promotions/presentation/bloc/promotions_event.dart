import 'package:quickpourmerchant/features/promotions/data/models/promotion_model.dart';

abstract class PromotionsEvent {}

class FetchMerchantPromotions extends PromotionsEvent {
  final String merchantId;
  FetchMerchantPromotions(this.merchantId);
}

class FetchActiveMerchantPromotions extends PromotionsEvent {
  final String merchantId;
  FetchActiveMerchantPromotions(this.merchantId);
}

class FetchPromotionsForProducts extends PromotionsEvent {
  final String merchantId;
  final List<String> productIds;
  FetchPromotionsForProducts(this.merchantId, this.productIds);
}

class CreatePromotion extends PromotionsEvent {
  final MerchantPromotionModel promotion;
  CreatePromotion(this.promotion);
}

class UpdatePromotion extends PromotionsEvent {
  final MerchantPromotionModel promotion;
  UpdatePromotion(this.promotion);
}

class DeletePromotion extends PromotionsEvent {
  final String promotionId;
  final String merchantId;
  DeletePromotion(this.promotionId, this.merchantId);
}

class IncrementPromotionUsage extends PromotionsEvent {
  final String promotionId;
  IncrementPromotionUsage(this.promotionId);
}
