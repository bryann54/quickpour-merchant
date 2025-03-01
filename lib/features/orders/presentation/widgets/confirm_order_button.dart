import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/order_tracking/presentation/bloc/order_tracking_bloc.dart';
import 'package:quickpourmerchant/features/order_tracking/presentation/pages/order_verification_screen.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';

class ConfirmOrderButton extends StatelessWidget {
  final CompletedOrder order;

  const ConfirmOrderButton({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 10, right: 10),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: BlocConsumer<OrderTrackingBloc, OrderTrackingState>(
          listener: (context, state) {
            if (state is OrderTrackingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is OrderTrackingLoaded &&
                state.order.status == 'processing') {
              // Navigate to verification page when status is updated to processing
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderVerificationPage(
                    orderId: state.order.id,
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final bool isUpdating = state is OrderTrackingUpdating;
            final bool isConfirmed = (state is OrderTrackingLoaded &&
                state.order.status == 'processing');

            return GestureDetector(
              onTap: isUpdating || isConfirmed
                  ? null
                  : () {
                      try {
                        print('Tapping confirm order for ID: ${order.id}');
                        if (order.id.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid order ID'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        context.read<OrderTrackingBloc>().add(
                              UpdateOrderStatus(
                                orderId: order.id,
                                newStatus: 'processing',
                              ),
                            );
                        print('Event added to bloc');
                      } catch (e) {
                        print('Error in confirm button: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isConfirmed ? Colors.green : AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isConfirmed ? 'Order Confirmed' : 'Confirm Order',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
