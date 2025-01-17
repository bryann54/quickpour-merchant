import 'package:bloc/bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(OrdersInitial()) {
    on<LoadOrdersFromCheckout>(_onLoadOrdersFromCheckout);
  }

  void _onLoadOrdersFromCheckout(
      LoadOrdersFromCheckout event, Emitter<OrdersState> emit) {}
}
