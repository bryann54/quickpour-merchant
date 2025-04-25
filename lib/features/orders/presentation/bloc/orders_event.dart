part of 'orders_bloc.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class StartOrdersStream extends OrdersEvent {}

class StopOrdersStream extends OrdersEvent {}

class RefreshOrders extends OrdersEvent {}

class OrdersUpdated extends OrdersEvent {
  final List<CompletedOrder> orders;

  const OrdersUpdated(this.orders);

  @override
  List<Object> get props => [orders];
}

class FilterOrdersByStatus extends OrdersEvent {
  final String? status;

  const FilterOrdersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class OrdersCountUpdated extends OrdersEvent {
  final int count;

  const OrdersCountUpdated(this.count);

  @override
  List<Object> get props => [count];
}

// update orderstatus
class UpdateOrderStatus extends OrdersEvent {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatus(this.orderId, this.newStatus);

  @override
  List<Object> get props => [orderId, newStatus];
}

class FeedbackCountUpdated extends OrdersEvent {
  final int count;

  const FeedbackCountUpdated(this.count);

  @override
  List<Object> get props => [count];
}
