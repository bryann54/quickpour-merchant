import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';

part 'order_tracking_event.dart';
part 'order_tracking_state.dart';

class OrderTrackingBloc extends Bloc<OrderTrackingEvent, OrderTrackingState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final CompletedOrder? initialOrder;

  OrderTrackingBloc({
    FirebaseFirestore? firestore,
    this.initialOrder,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(initialOrder != null
            ? OrderTrackingLoaded(order: initialOrder, verifiedItems: {})
            : OrderTrackingInitial()) {
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<VerifyOrderItem>(_onVerifyOrderItem);
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<MarkOrderAsDispatched>(_onMarkOrderAsDispatched);
    on<ResetOrderTracking>(_onResetOrderTracking);
  }

  String? get currentMerchantId => _auth.currentUser?.uid;

  Future<void> _onLoadOrderDetails(
      LoadOrderDetails event, Emitter<OrderTrackingState> emit) async {
    try {
      emit(OrderTrackingLoading());

      // Fetch the latest order details to ensure we have current data
      final DocumentSnapshot orderSnapshot =
          await _firestore.collection('orders').doc(event.orderId).get();

      if (!orderSnapshot.exists) {
        emit(OrderTrackingError('Order not found'));
        return;
      }

      final orderData = orderSnapshot.data() as Map<String, dynamic>;
      final order = CompletedOrder.fromFirebase(orderData, event.orderId);

      // Create a map to track verified items
      final Map<String, bool> verifiedItems = {};

      // Initialize all items as unverified
      for (var merchantOrder in order.merchantOrders) {
        if (merchantOrder.merchantId == currentMerchantId) {
          for (var item in merchantOrder.items) {
            verifiedItems[item.productId] = false;
          }
        }
      }

      emit(OrderTrackingLoaded(
        order: order,
        verifiedItems: verifiedItems,
      ));
    } catch (e) {
      emit(OrderTrackingError('Failed to load order details: $e'));
    }
  }

Future<void> _onUpdateOrderStatus(
      UpdateOrderStatus event, Emitter<OrderTrackingState> emit) async {
    try {
      final currentState = state;
      if (currentState is OrderTrackingLoaded) {
        emit(OrderTrackingUpdating(
          order: currentState.order,
          verifiedItems: currentState.verifiedItems,
        ));

        print('Updating order ${event.orderId} to ${event.newStatus}');

        // Check if orderId exists
        if (event.orderId.isEmpty) {
          throw Exception('Order ID is empty');
        }

        // Check if currentMerchantId exists
        if (currentMerchantId == null) {
          throw Exception('Current merchant ID is null');
        }

        // Try to get the document first to verify it exists
        try {
          final docSnapshot =
              await _firestore.collection('orders').doc(event.orderId).get();
          if (!docSnapshot.exists) {
            throw Exception('Order document does not exist');
          }
          print('Document exists, proceeding with update');
        } catch (e) {
          print('Error checking document: $e');
          throw Exception('Failed to verify document: $e');
        }

        // Try the update with a timeout
        try {
          await _firestore.collection('orders').doc(event.orderId).update({
            'status': event.newStatus,
            'lastUpdated': FieldValue.serverTimestamp(),
            'statusHistory': FieldValue.arrayUnion([
              {
                'status': event.newStatus,
                'timestamp': FieldValue.serverTimestamp(),
                'updatedBy': currentMerchantId,
              }
            ]),
          }).timeout(Duration(seconds: 10), onTimeout: () {
            throw TimeoutException('Firebase update timed out');
          });
          print('Firestore update successful');
        } catch (firebaseError) {
          print('Firebase update error: $firebaseError');
          throw Exception('Firebase update failed: $firebaseError');
        }

        // Only proceed if we didn't throw an exception above
        final updatedOrder = currentState.order.copyWith(
          status: event.newStatus,
        );

        emit(OrderTrackingLoaded(
          order: updatedOrder,
          verifiedItems: currentState.verifiedItems,
        ));
        print('Order status updated successfully');
      } else {
        print('Cannot update status: Order not loaded');
        emit(OrderTrackingError('Cannot update status: Order not loaded'));
      }
    } catch (e) {
      print('Order update error: $e');
      emit(OrderTrackingError('Failed to update order status: $e'));
    }
  }
 
  void _onVerifyOrderItem(
      VerifyOrderItem event, Emitter<OrderTrackingState> emit) {
    final currentState = state;
    if (currentState is OrderTrackingLoaded) {
      final updatedVerifiedItems =
          Map<String, bool>.from(currentState.verifiedItems);
      updatedVerifiedItems[event.productId] = event.isVerified;

      emit(OrderTrackingLoaded(
        order: currentState.order,
        verifiedItems: updatedVerifiedItems,
      ));
    }
  }

  Future<void> _onMarkOrderAsDispatched(
      MarkOrderAsDispatched event, Emitter<OrderTrackingState> emit) async {
    try {
      final currentState = state;
      if (currentState is OrderTrackingLoaded) {
        emit(OrderTrackingUpdating(
          order: currentState.order,
          verifiedItems: currentState.verifiedItems,
        ));

        // Check if all items are verified
        bool allItemsVerified =
            !currentState.verifiedItems.values.contains(false);

        if (!allItemsVerified && !event.forceDispatch) {
          emit(OrderTrackingError(
            'All items must be verified before dispatching',
            order: currentState.order,
            verifiedItems: currentState.verifiedItems,
          ));
          return;
        }

        // Update the order status in Firestore
        await _firestore
            .collection('orders')
            .doc(currentState.order.id)
            .update({
          'status': 'dispatched',
          'dispatchedAt': FieldValue.serverTimestamp(),
          'dispatchedBy': currentMerchantId,
          'lastUpdated': FieldValue.serverTimestamp(),
          'statusHistory': FieldValue.arrayUnion([
            {
              'status': 'dispatched',
              'timestamp': FieldValue.serverTimestamp(),
              'updatedBy': currentMerchantId,
            }
          ]),
        });

        final updatedOrder = currentState.order.copyWith(
          status: 'dispatched',
        );

        emit(OrderDispatched(
          order: updatedOrder,
          verifiedItems: currentState.verifiedItems,
        ));
      } else {
        emit(OrderTrackingError('Cannot dispatch: Order not loaded'));
      }
    } catch (e) {
      final currentState = state;
      if (currentState is OrderTrackingLoaded) {
        emit(OrderTrackingError(
          'Failed to dispatch order: $e',
          order: currentState.order,
          verifiedItems: currentState.verifiedItems,
        ));
      } else {
        emit(OrderTrackingError('Failed to dispatch order: $e'));
      }
    }
  }

  void _onResetOrderTracking(
      ResetOrderTracking event, Emitter<OrderTrackingState> emit) {
    emit(OrderTrackingInitial());
  }
}
