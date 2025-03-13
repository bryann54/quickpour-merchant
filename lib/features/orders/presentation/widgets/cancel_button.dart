import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';

class CancelOrderButton extends StatelessWidget {
  final String orderId;
  final VoidCallback? onCancelled;

  const CancelOrderButton({
    super.key,
    required this.orderId,
    this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return ElevatedButton(
      onPressed: () => _showCancellationDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade700,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side:const BorderSide(color: Colors.black26, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        'Cancel Order',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showCancellationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Text(
            'Cancel Order',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          content: const Text(
            'Are you sure you want to cancel this order? This action cannot be undone.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              child: const Text('cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update status to canceled
                context
                    .read<OrdersBloc>()
                    .add(UpdateOrderStatus(orderId, 'canceled'));

                // Close dialog
                Navigator.pop(context);

                // Execute callback if provided
                if (onCancelled != null) {
                  onCancelled!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                // foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('ok'),
            ),
          ],
          actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        );
      },
    );
  }
}
