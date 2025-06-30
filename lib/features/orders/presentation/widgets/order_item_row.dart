import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/function_utils.dart';
import 'package:quickpourmerchant/features/orders/data/models/order_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/quantity_badge_widget.dart';

class OrderItemRow extends StatelessWidget {
  final OrderItem item;

  const OrderItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          if (item.images.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.images.first,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorWidget: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  color: isDark ? Colors.grey : Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.error,
                color: isDark ? Colors.grey.shade600 : Colors.grey[400],
              ),
            ),
          const SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                // Text(

                //   item.measure,
                //   style: TextStyle(
                //     fontSize: 12,
                //     fontWeight: FontWeight.w500,
                //     color: isDark
                //         ? AppColors.textPrimaryDark
                //         : AppColors.textPrimary,
                //   ),
                // ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ksh ${formatMoney(item.price)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.accentColorDark
                            : AppColors.accentColor,
                      ),
                    ),
                    QuantityBadge(quantity: item.quantity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
