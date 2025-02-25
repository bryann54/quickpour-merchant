part of 'orders_bloc.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersEmpty extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<CompletedOrder> orders;
  final List<CompletedOrder> allOrders;
  final int? ordersCount;
  final int? feedbackCount;
  final String? statusFilter;

  const OrdersLoaded(
    this.orders, {
    List<CompletedOrder>? allOrders,
    this.ordersCount,
    this.feedbackCount,
    this.statusFilter,
  }) : allOrders = allOrders ?? orders;

  @override
  List<Object?> get props =>
      [orders, allOrders, ordersCount, feedbackCount, statusFilter];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
