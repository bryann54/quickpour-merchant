import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/order_item_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
      body: BlocProvider(
        create: (_) => OrdersBloc()..add(LoadOrdersFromCheckout()),
        child: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrdersEmpty) {
              return _buildEmptyOrdersView(context);
            } else if (state is OrdersLoaded) {
              return _buildOrdersList(context, state.orders);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersView(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.boxOpen,
            size: 50,
            color: AppColors.brandAccent,
          ),
          SizedBox(height: 20),
          Text(
            'No orders yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<CompletedOrder> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderItemWidget(order: order);
      },
    );
  }
}
