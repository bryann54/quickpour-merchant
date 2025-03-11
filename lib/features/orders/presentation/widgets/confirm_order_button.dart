import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/orders/data/models/order_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/order_confirmation_screen.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';

class ConfirmOrderButton extends StatelessWidget {
  final List<OrderItem> items;
  final String orderId;
  final String newStatus; // Usually 'confirmed' or similar

  const ConfirmOrderButton({
    super.key,
    required this.items,
    required this.orderId,
    this.newStatus = 'processing', // Default status
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 10, right: 10),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {
            // Update status in Firebase
            context
                .read<OrdersBloc>()
                .add(UpdateOrderStatus(orderId, newStatus));

            // Show confirmation screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderConfirmationScreen(items: items),
              ),
            );
          },
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Confirm Order',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
