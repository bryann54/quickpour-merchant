import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/order_tracking/presentation/bloc/order_tracking_bloc.dart';

class OrderVerificationPage extends StatelessWidget {
  final String orderId;

  const OrderVerificationPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderTrackingBloc()..add(LoadOrderDetails(orderId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Order Items'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: BlocConsumer<OrderTrackingBloc, OrderTrackingState>(
          listener: (context, state) {
            if (state is OrderTrackingError) {
              print('Error: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is OrderDispatched) {
              print('Order dispatched successfully');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order dispatched successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context); // Navigate back after dispatching
            }
          },
          builder: (context, state) {
            if (state is OrderTrackingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderTrackingLoaded) {
              return _buildOrderVerificationUI(context, state);
            } else if (state is OrderTrackingError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('No order data available.'));
            }
          },
        ),
        floatingActionButton:
            BlocBuilder<OrderTrackingBloc, OrderTrackingState>(
          builder: (context, state) {
            if (state is OrderTrackingLoaded) {
              return FloatingActionButton(
                onPressed: () {
                  print('Dispatch button tapped');
                  if (state.allItemsVerified) {
                    context
                        .read<OrderTrackingBloc>()
                        .add(MarkOrderAsDispatched());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Please verify all items before dispatching.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                backgroundColor: state.allItemsVerified
                    ? AppColors.primaryColor
                    : Colors.grey,
                child: const Icon(Icons.delivery_dining),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOrderVerificationUI(
      BuildContext context, OrderTrackingLoaded state) {
    final order = state.order;
    final verifiedItems = state.verifiedItems;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ID: ${order.id}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Status: ${order.status}',
            style: TextStyle(
              fontSize: 16,
              color:
                  order.status == 'dispatched' ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Items to Verify:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...order.merchantOrders.map((merchantOrder) {
            if (merchantOrder.merchantId ==
                context.read<OrderTrackingBloc>().currentMerchantId) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchantOrder.merchantStoreName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ...merchantOrder.items.map((item) {
                    return CheckboxListTile(
                      title: Text(item.productName),
                      subtitle: Text('Quantity: ${item.quantity}'),
                      value: verifiedItems[item.productId],
                      onChanged: (bool? value) {
                        context.read<OrderTrackingBloc>().add(
                              VerifyOrderItem(
                                productId: item.productId,
                                isVerified: value ?? false,
                              ),
                            );
                      },
                    );
                  }).toList(),
                ],
              );
            }
            return const SizedBox.shrink();
          }).toList(),
          const SizedBox(height: 20),
          Text(
            'Verified Items: ${state.verifiedItemsCount}/${state.totalItemsCount}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
