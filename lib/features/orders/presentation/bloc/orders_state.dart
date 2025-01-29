part of 'orders_bloc.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersEmpty extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<CompletedOrder> orders;
  final int? ordersCount;
  final int? feedbackCount;

  const OrdersLoaded(
    this.orders, {
    this.ordersCount,
    this.feedbackCount,
  });

  @override
  List<Object?> get props => [orders, ordersCount, feedbackCount];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
