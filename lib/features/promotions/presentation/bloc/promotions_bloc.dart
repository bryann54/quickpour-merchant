import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/promotions/data/repositories/promotions_repository.dart';
import 'package:quickpourmerchant/features/promotions/presentation/bloc/promotions_event.dart';
import 'package:quickpourmerchant/features/promotions/presentation/bloc/promotions_state.dart';
import 'package:uuid/uuid.dart';

class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  final PromotionsRepository promotionsRepository;

  PromotionsBloc(this.promotionsRepository) : super(PromotionsInitial()) {
    on<FetchMerchantPromotions>(_onFetchMerchantPromotions);
    on<FetchActiveMerchantPromotions>(_onFetchActiveMerchantPromotions);
    on<FetchPromotionsForProducts>(_onFetchPromotionsForProducts);
    on<CreatePromotion>(_onCreatePromotion);
    on<UpdatePromotion>(_onUpdatePromotion);
    on<DeletePromotion>(_onDeletePromotion);
    on<IncrementPromotionUsage>(_onIncrementPromotionUsage);
  }

  Future<void> _onFetchMerchantPromotions(
    FetchMerchantPromotions event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(PromotionsLoading());
    try {
      final promotions = await promotionsRepository.fetchMerchantPromotions(
        event.merchantId,
      );
      emit(PromotionsLoaded(promotions));
    } catch (e) {
      emit(PromotionsError(e.toString()));
    }
  }

  Future<void> _onFetchActiveMerchantPromotions(
    FetchActiveMerchantPromotions event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(PromotionsLoading());
    try {
      final promotions =
          await promotionsRepository.fetchActiveMerchantPromotions(
        event.merchantId,
      );
      emit(PromotionsLoaded(promotions));
    } catch (e) {
      emit(PromotionsError(e.toString()));
    }
  }

  Future<void> _onFetchPromotionsForProducts(
    FetchPromotionsForProducts event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(PromotionsLoading());
    try {
      final promotions = await promotionsRepository.fetchPromotionsForProducts(
        event.merchantId,
        event.productIds,
      );
      emit(PromotionsLoaded(promotions));
    } catch (e) {
      emit(PromotionsError(e.toString()));
    }
  }

  Future<void> _onCreatePromotion(
    CreatePromotion event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(PromotionsLoading());
    try {
      // Generate a new UUID if not provided
      final promotion = event.promotion.id.isEmpty
          ? event.promotion.copyWith(id: const Uuid().v4())
          : event.promotion;

      await promotionsRepository.createPromotion(promotion);

      // Refresh promotions list for this merchant
      final promotions = await promotionsRepository.fetchMerchantPromotions(
        promotion.merchantId,
      );
      emit(PromotionCreated(promotion));
      emit(PromotionsLoaded(promotions));
    } catch (e) {
      emit(PromotionsError(e.toString()));
    }
  }

  Future<void> _onUpdatePromotion(
    UpdatePromotion event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(PromotionsLoading());
    try {
      await promotionsRepository.updatePromotion(event.promotion);

      // Refresh promotions list for this merchant
      final promotions = await promotionsRepository.fetchMerchantPromotions(
        event.promotion.merchantId,
      );
      emit(PromotionUpdated(event.promotion));
      emit(PromotionsLoaded(promotions));
    } catch (e) {
      emit(PromotionsError(e.toString()));
    }
  }

  Future<void> _onDeletePromotion(
    DeletePromotion event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(PromotionsLoading());
    try {
      // Use soft delete for better data integrity
      await promotionsRepository.softDeletePromotion(event.promotionId);

      // Refresh promotions list for this merchant
      final promotions = await promotionsRepository.fetchMerchantPromotions(
        event.merchantId,
      );
      emit(PromotionDeleted(event.promotionId));
      emit(PromotionsLoaded(promotions));
    } catch (e) {
      emit(PromotionsError(e.toString()));
    }
  }

  Future<void> _onIncrementPromotionUsage(
    IncrementPromotionUsage event,
    Emitter<PromotionsState> emit,
  ) async {
    try {
      await promotionsRepository.incrementPromotionUsage(event.promotionId);
      emit(PromotionUsageIncremented(event.promotionId));
    } catch (e) {
      emit(PromotionsError(e.toString()));
    }
  }
}
