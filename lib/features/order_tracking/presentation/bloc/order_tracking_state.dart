part of 'order_tracking_bloc.dart';

abstract class OrderTrackingState extends Equatable {
  const OrderTrackingState();

  @override
  List<Object?> get props => [];
}

class OrderTrackingInitial extends OrderTrackingState {}

class OrderTrackingLoading extends OrderTrackingState {}

class OrderTrackingLoaded extends OrderTrackingState {
  final CompletedOrder order;
  final Map<String, bool> verifiedItems;

  const OrderTrackingLoaded({
    required this.order,
    required this.verifiedItems,
  });

  bool get allItemsVerified => !verifiedItems.values.contains(false);
  int get verifiedItemsCount => verifiedItems.values.where((v) => v).length;
  int get totalItemsCount => verifiedItems.length;

  @override
  List<Object> get props => [order, verifiedItems];
}

class OrderTrackingUpdating extends OrderTrackingLoaded {
  const OrderTrackingUpdating({
    required super.order,
    required super.verifiedItems,
  });
}

class OrderDispatched extends OrderTrackingLoaded {
  const OrderDispatched({
    required super.order,
    required super.verifiedItems,
  });
}

class OrderTrackingError extends OrderTrackingState {
  final String message;
  final CompletedOrder? order;
  final Map<String, bool>? verifiedItems;

  const OrderTrackingError(
    this.message, {
    this.order,
    this.verifiedItems,
  });

  @override
  List<Object?> get props => [message, order, verifiedItems];
}
