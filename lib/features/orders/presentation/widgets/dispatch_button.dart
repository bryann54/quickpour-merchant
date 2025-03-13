import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/rider_selection_screen.dart';

class DispatchButton extends StatelessWidget {
  final String orderId;
  final int selectedCount;
  final bool isLoading;
  final VoidCallback onDispatchStarted;
  final VoidCallback onDispatchCompleted;

  const DispatchButton({
    Key? key,
    required this.orderId,
    required this.selectedCount,
    required this.isLoading,
    required this.onDispatchStarted,
    required this.onDispatchCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        final bool isProcessing =
            state is OrderStatusUpdating && state.orderId == orderId;

        return ElevatedButton(
          onPressed: selectedCount == 0 || isProcessing || isLoading
              ? null
              : () {
                  // Call the dispatch started callback
                  onDispatchStarted();

                  // Navigate to the rider selection screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RiderSelectionScreen(
                        orderId: orderId,
                        selectedItemCount: selectedCount,
                        onDispatchCompleted: () {
                          // Call the completion callback
                          onDispatchCompleted();

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$selectedCount item(s) completed successfully!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 54),
          ),
          child: isProcessing || isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(selectedCount == 0
                        ? null
                        : Icons.local_shipping_outlined),
                    const SizedBox(width: 8),
                    Text(
                      selectedCount == 0
                          ? 'Select Items to Dispatch'
                          : 'Select Rider & Track Order',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
