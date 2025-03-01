import 'package:flutter/material.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/date_formatter.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/order_details_screen.dart';
import 'package:intl/intl.dart';

class OrderItemWidget extends StatelessWidget {
  final CompletedOrder order;

  const OrderItemWidget({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

  



    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header row
              Row(
                children: [
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getStatusColor(order.status,isDarkMode).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: getStatusColor(order.status,isDarkMode),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatStatus(order.status),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: getStatusColor(order.status,isDarkMode),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Payment method icon
                 
                  Icon(
                    order.paymentMethod.toLowerCase().contains('card')
                        ? Icons.credit_card
                        : Icons.money,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
             Text(
                    order.paymentMethod,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Order ID and price
                    Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Order #${order.id}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Ksh ${formatMoney( order.total)} ',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppColors.brandAccent.withOpacity(.8)
                            : AppColors.primaryColor,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              


              const SizedBox(height: 4),

              // Date
              Text(
                DateFormat('MMM d, yyyy • h:mm a').format(order.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Customer info
              Row(
                children: [
                  // Customer avatar
                  Hero(
                   tag:
                   'customer-avatar-${order.id}',
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: isDarkMode
                          ? AppColors.brandAccent.withOpacity(0.2)
                          : AppColors.primaryColor.withOpacity(0.1),
                      child: Text(
                        order.userName.isNotEmpty
                            ? order.userName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: isDarkMode
                              ? AppColors.brandAccent
                              : AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Customer details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.userName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
       Row(
                          children: [
                            Icon(
                              order.deliveryType
                                      .toLowerCase()
                                      .contains('express')
                                  ? Icons
                                      .rocket_launch // Rocket icon for express
                                  : order.deliveryType
                                          .toLowerCase()
                                          .contains('standard')
                                      ? Icons
                                          .local_shipping // Truck icon for standard
                                      : Icons.store, // Store icon for pickup
                              size: 14,
                              color: order.deliveryType
                                      .toLowerCase()
                                      .contains('express')
                                  ? Colors.orange // Orange for express
                                  : order.deliveryType
                                          .toLowerCase()
                                          .contains('standard')
                                      ? Colors.blue // Blue for standard
                                      : Colors.green, // Green for pickup
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.deliveryType,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: order.deliveryType
                                        .toLowerCase()
                                        .contains('express')
                                    ? Colors.orange // Orange for express
                                    : order.deliveryType
                                            .toLowerCase()
                                            .contains('standard')
                                        ? Colors.blue // Blue for standard
                                        : Colors.green, // Green for pickup
                              ),
                            ),
                          ],
                        ),   ],
                    ),
                  ),

                  // View details button
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.brandAccent.withOpacity(0.15)
                          : AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: isDarkMode
                          ? AppColors.brandAccent
                          : AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
