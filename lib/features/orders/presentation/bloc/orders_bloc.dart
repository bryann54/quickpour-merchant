import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';
import 'package:quickpourmerchant/features/orders/data/models/order_model.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(OrdersInitial()) {
    on<LoadOrdersFromCheckout>(_onLoadOrdersFromCheckout);
  }

  void _onLoadOrdersFromCheckout(
      LoadOrdersFromCheckout event, Emitter<OrdersState> emit) async {
    emit(OrdersInitial());
    try {
      final ordersSnapshot =
          await FirebaseFirestore.instance.collection('orders').get();

      final orders = ordersSnapshot.docs.map((doc) {
        final data = doc.data();

        return CompletedOrder(
          id: data['orderId'] ?? '',
          date:
              DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
          total: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
          address: data['address'] as String?,
          phoneNumber: data['phoneNumber'] as String?,
          paymentMethod: data['paymentMethod'] ?? '',
          items: (data['cartItems'] as List<dynamic>)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList(),
          deliveryTime: data['deliveryTime'] ?? '',
          specialInstructions: data['specialInstructions'] ?? '',
          status: data['status'] ?? '',
          userEmail: data['userEmail'] ?? '',
          
          userName: data['userName'] ?? '',
        );
      }).toList();

      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError('Failed to load orders: ${e.toString()}'));
    }
  }
}
