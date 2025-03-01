import 'package:flutter/material.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/date_formatter.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';

class OrderTotalRow extends StatelessWidget {
  final CompletedOrder order;

  const OrderTotalRow({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(  
        color: isDark
            ? AppColors.cardColorDark.withOpacity(0.8)
            : AppColors.surface.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          //   Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       'delivery fee',
          //       style: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //         color: isDark
          //             ? AppColors.textPrimaryDark
          //             : AppColors.textPrimary,
          //       ),
          //     ),
          //     Text(
          //       'Ksh ${formatMoney(order.deliveryFee)}',
          //       style: TextStyle(
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //         color: isDark
          //             ? AppColors.accentColorDark
          //             : AppColors.accentColor,
          //       ),
          //     ),
          //   ],
          // ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'order Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                'Ksh ${formatMoney(order.total)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.accentColorDark
                      : AppColors.accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
