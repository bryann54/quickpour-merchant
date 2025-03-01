part of 'order_tracking_bloc.dart';

abstract class OrderTrackingEvent extends Equatable {
  const OrderTrackingEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderDetails extends OrderTrackingEvent {
  final String orderId;

  const LoadOrderDetails(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class UpdateOrderStatus extends OrderTrackingEvent {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatus({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object> get props => [orderId, newStatus];
}

class VerifyOrderItem extends OrderTrackingEvent {
  final String productId;
  final bool isVerified;

  const VerifyOrderItem({
    required this.productId,
    required this.isVerified,
  });

  @override
  List<Object> get props => [productId, isVerified];
}

class MarkOrderAsDispatched extends OrderTrackingEvent {
  final bool forceDispatch;

  const MarkOrderAsDispatched({this.forceDispatch = false});

  @override
  List<Object> get props => [forceDispatch];
}

class ResetOrderTracking extends OrderTrackingEvent {}
