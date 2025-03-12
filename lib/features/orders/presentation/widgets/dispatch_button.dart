import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';

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
    return ElevatedButton(
      onPressed: selectedCount == 0
          ? null
          : () async {
              onDispatchStarted();

              // Update status in Firebase
              context.read<OrdersBloc>().add(
                    UpdateOrderStatus(orderId, 'dispatched'),
                  );

              // Simulate processing time (you might want to remove this in production)
              await Future.delayed(const Duration(seconds: 2));

              // Call the completion callback
              onDispatchCompleted();

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$selectedCount item(s) dispatched successfully!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate back
              Navigator.pop(context);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 54),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_shipping_outlined),
          const SizedBox(width: 8),
          Text(
            selectedCount == 0
                ? 'Select Items to Dispatch'
                : 'Dispatch Selected Items',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
