import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';
import 'package:quickpourmerchant/features/orders/data/repositories/orders_repository.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository _ordersRepository;
  StreamSubscription<List<CompletedOrder>>? _ordersSubscription;
  StreamSubscription<int>? _ordersCountSubscription;
  StreamSubscription<int>? _feedbackCountSubscription;

  OrdersBloc({OrdersRepository? ordersRepository})
      : _ordersRepository = ordersRepository ?? OrdersRepository(),
        super(OrdersInitial()) {
    on<StartOrdersStream>(_onStartOrdersStream);
    on<OrdersUpdated>(_onOrdersUpdated);
    on<StopOrdersStream>(_onStopOrdersStream);
    on<OrdersCountUpdated>(_onOrdersCountUpdated);
    on<FeedbackCountUpdated>(_onFeedbackCountUpdated);
  }

  void _onStartOrdersStream(
      StartOrdersStream event, Emitter<OrdersState> emit) {
    emit(OrdersInitial());

    // Start orders stream
    _ordersSubscription?.cancel();
    _ordersSubscription = _ordersRepository.streamOrders().listen(
      (orders) {
        add(OrdersUpdated(orders));
      },
      onError: (error) {
        emit(OrdersError('Failed to load orders: $error'));
      },
    );

    // Start counts streams
    _ordersCountSubscription?.cancel();
    _ordersCountSubscription = _ordersRepository.streamOrdersCount().listen(
      (count) {
        add(OrdersCountUpdated(count));
      },
      onError: (error) {
        emit(OrdersError('Failed to load orders count: $error'));
      },
    );

    _feedbackCountSubscription?.cancel();
    _feedbackCountSubscription = _ordersRepository.streamFeedbackCount().listen(
      (count) {
        add(FeedbackCountUpdated(count));
      },
      onError: (error) {
        emit(OrdersError('Failed to load feedback count: $error'));
      },
    );
  }

  void _onOrdersUpdated(OrdersUpdated event, Emitter<OrdersState> emit) {
    if (event.orders.isEmpty) {
      emit(OrdersEmpty());
    } else {
      final currentState = state;
      if (currentState is OrdersLoaded) {
        emit(OrdersLoaded(
          event.orders,
          ordersCount: currentState.ordersCount,
          feedbackCount: currentState.feedbackCount,
        ));
      } else {
        emit(OrdersLoaded(event.orders));
      }
    }
  }

  void _onOrdersCountUpdated(
      OrdersCountUpdated event, Emitter<OrdersState> emit) {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(OrdersLoaded(
        currentState.orders,
        ordersCount: event.count,
        feedbackCount: currentState.feedbackCount,
      ));
    }
  }

  void _onFeedbackCountUpdated(
      FeedbackCountUpdated event, Emitter<OrdersState> emit) {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(OrdersLoaded(
        currentState.orders,
        ordersCount: currentState.ordersCount,
        feedbackCount: event.count,
      ));
    }
  }

  void _onStopOrdersStream(StopOrdersStream event, Emitter<OrdersState> emit) {
    _ordersSubscription?.cancel();
    _ordersCountSubscription?.cancel();
    _feedbackCountSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    _ordersCountSubscription?.cancel();
    _feedbackCountSubscription?.cancel();
    return super.close();
  }
}
