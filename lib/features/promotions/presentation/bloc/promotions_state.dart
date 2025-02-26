import 'package:quickpourmerchant/features/promotions/data/models/promotion_model.dart';

abstract class PromotionsState {}

class PromotionsInitial extends PromotionsState {}

class PromotionsLoading extends PromotionsState {}

class PromotionsLoaded extends PromotionsState {
  final List<MerchantPromotionModel> promotions;
  PromotionsLoaded(this.promotions);
}

class PromotionCreated extends PromotionsState {
  final MerchantPromotionModel promotion;
  PromotionCreated(this.promotion);
}

class PromotionUpdated extends PromotionsState {
  final MerchantPromotionModel promotion;
  PromotionUpdated(this.promotion);
}

class PromotionDeleted extends PromotionsState {
  final String promotionId;
  PromotionDeleted(this.promotionId);
}

class PromotionUsageIncremented extends PromotionsState {
  final String promotionId;
  PromotionUsageIncremented(this.promotionId);
}

class PromotionsError extends PromotionsState {
  final String message;
  PromotionsError(this.message);
}
