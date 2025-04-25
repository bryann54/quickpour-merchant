import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/orders/data/models/order_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/order_confirmation_screen.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';

class ConfirmOrderButton extends StatelessWidget {
  final List<OrderItem> items;
  final String orderId;
  final String newStatus;

  const ConfirmOrderButton({
    super.key,
    required this.items,
    required this.orderId,
    this.newStatus = 'processing',
    required Null Function() onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: ElevatedButton(
        onPressed: () {
          // Update status in Firebase
          context.read<OrdersBloc>().add(UpdateOrderStatus(orderId, newStatus));

          // Show confirmation screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderConfirmationScreen(
                items: items,
                orderId: orderId,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 54),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, size: 20),
            SizedBox(width: 8),
            Text(
              'Confirm Order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
