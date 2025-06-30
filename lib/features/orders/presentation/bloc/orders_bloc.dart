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
    on<FilterOrdersByStatus>(_onFilterOrdersByStatus);
    on<RefreshOrders>(_onRefreshOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
  }

  void _onStartOrdersStream(
      StartOrdersStream event, Emitter<OrdersState> emit) {
    emit(OrdersLoading());

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
      final List<CompletedOrder> filteredOrders = event.orders;

      if (currentState is OrdersLoaded) {
        // If we have a status filter applied, maintain it
        final filteredOrders = currentState.statusFilter != null
            ? event.orders
                .where((order) => order.status == currentState.statusFilter)
                .toList()
            : event.orders;

        emit(OrdersLoaded(
          filteredOrders,
          allOrders: event.orders,
          ordersCount: currentState.ordersCount,
          feedbackCount: currentState.feedbackCount,
          statusFilter: currentState.statusFilter,
        ));
      } else {
        emit(OrdersLoaded(
          filteredOrders,
          allOrders: event.orders,
        ));
      }
    }
  }

  void _onFilterOrdersByStatus(
      FilterOrdersByStatus event, Emitter<OrdersState> emit) {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      final filteredOrders = event.status != null
          ? currentState.allOrders
              .where((order) => order.status == event.status)
              .toList()
          : currentState.allOrders;

      emit(OrdersLoaded(
        filteredOrders,
        allOrders: currentState.allOrders,
        ordersCount: currentState.ordersCount,
        feedbackCount: currentState.feedbackCount,
        statusFilter: event.status,
      ));
    }
  }

  void _onRefreshOrders(RefreshOrders event, Emitter<OrdersState> emit) async {
    try {
      emit(OrdersLoading());
      final orders = await _ordersRepository.getOrders();
      add(OrdersUpdated(orders));
    } catch (e) {
      emit(OrdersError('Failed to refresh orders: $e'));
    }
  }

  void _onOrdersCountUpdated(
      OrdersCountUpdated event, Emitter<OrdersState> emit) {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(OrdersLoaded(
        currentState.orders,
        allOrders: currentState.allOrders,
        ordersCount: event.count,
        feedbackCount: currentState.feedbackCount,
        statusFilter: currentState.statusFilter,
      ));
    }
  }

  void _onFeedbackCountUpdated(
      FeedbackCountUpdated event, Emitter<OrdersState> emit) {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(OrdersLoaded(
        currentState.orders,
        allOrders: currentState.allOrders,
        ordersCount: currentState.ordersCount,
        feedbackCount: event.count,
        statusFilter: currentState.statusFilter,
      ));
    }
  }

  void _onUpdateOrderStatus(
      UpdateOrderStatus event, Emitter<OrdersState> emit) async {
    final currentState = state;
    // Preserve the current state's data
    if (currentState is OrdersLoaded) {
      emit(OrderStatusUpdating(event.orderId));
      try {
        await _ordersRepository.updateOrderStatus(
            event.orderId, event.newStatus);
        emit(OrderStatusUpdated(event.orderId, event.newStatus));
        // Restore previous state after update confirmation
        emit(currentState);
        // The stream will automatically update the UI with the new data
      } catch (e) {
        emit(OrdersError('Failed to update order status: $e'));
        // Restore previous state after error
        emit(currentState);
      }
    }
  }

  void _onStopOrdersStream(StopOrdersStream event, Emitter<OrdersState> emit) {
    _cancelSubscriptions();
  }

  void _cancelSubscriptions() {
    _ordersSubscription?.cancel();
    _ordersCountSubscription?.cancel();
    _feedbackCountSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
