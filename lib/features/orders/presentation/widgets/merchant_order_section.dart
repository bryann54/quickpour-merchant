import 'package:flutter/material.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/date_formatter.dart';
import 'package:quickpourmerchant/features/orders/data/models/merchant_order_item_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/order_item_row.dart';

// merchant_order_section.dart
class MerchantOrderSection extends StatelessWidget {
  final MerchantOrderItem merchantOrder;

  const MerchantOrderSection({super.key, required this.merchantOrder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardColorDark.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Items list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: merchantOrder.items.length,
            separatorBuilder: (context, index) => const Divider(height: 6),
            itemBuilder: (context, index) => OrderItemRow(
              item: merchantOrder.items[index],
            ),
          ),

          // Merchant subtotal
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[50],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Subtotal',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Ksh ${formatMoney(merchantOrder.subtotal)}',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.accentColorDark
                        : AppColors.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
