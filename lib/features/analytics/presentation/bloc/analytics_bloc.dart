import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quickpourmerchant/features/orders/data/repositories/orders_repository.dart';
import 'package:quickpourmerchant/features/product/data/repositories/product_repository.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final ProductRepository productRepository;
  final OrdersRepository ordersRepository;

  AnalyticsBloc({
    required this.productRepository,
    required this.ordersRepository,
  }) : super(AnalyticsInitial()) {
    on<FetchAnalyticsData>((event, emit) async {
      emit(AnalyticsLoading());

      try {
        final stockCount = await productRepository.fetchStockCount();
        final ordersCount = await ordersRepository.fetchOrdersCount();
        final feedbackCount = await ordersRepository.fetchFeedbackCount();

        emit(AnalyticsLoaded(
          stockCount: stockCount,
          ordersCount: ordersCount,
          feedbackCount: feedbackCount,
        ));
      } catch (e) {
        emit(AnalyticsError('Failed to fetch analytics}'));
      }
    });
  }
}
