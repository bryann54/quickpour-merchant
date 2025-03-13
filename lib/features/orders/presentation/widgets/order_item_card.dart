import 'package:flutter/material.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/date_formatter.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';
import 'package:quickpourmerchant/features/orders/data/models/order_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/order_details_screen.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/order_confirmation_screen.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/order_tracking_screen.dart';
import 'package:intl/intl.dart';

class OrderItemWidget extends StatelessWidget {
  final CompletedOrder order;

  const OrderItemWidget({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Helper function to get the order status enum
    OrderStatus orderStatus = _getOrderStatus(order.status);

    return InkWell(
      onTap: () {
        _navigateBasedOnStatus(context, orderStatus);
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
                      color: getStatusColor(order.status, isDarkMode)
                          .withOpacity(0.15),
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
                            color: getStatusColor(order.status, isDarkMode),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatStatus(order.status),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: getStatusColor(order.status, isDarkMode),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Payment method icon
                  Icon(
                    getPaymentMethodIcon(order.paymentMethod),
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
                      'Ksh ${formatMoney(order.total)} ',
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
                    tag: 'customer-avatar-${order.id}',
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
                        ),
                      ],
                    ),
                  ),

                  // View details button with appropriate action hint
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.brandAccent.withOpacity(0.15)
                          : AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: _getActionIcon(orderStatus, isDarkMode),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get the appropriate action icon based on status
  Widget _getActionIcon(OrderStatus status, bool isDarkMode) {
    switch (status) {
      case OrderStatus.received:
        return Icon(
          Icons.edit_document,
          size: 14,
          color: isDarkMode ? AppColors.brandAccent : AppColors.primaryColor,
        );
      case OrderStatus.processing:
        return Icon(
          Icons.inventory_2,
          size: 14,
          color: isDarkMode ? AppColors.brandAccent : AppColors.primaryColor,
        );
      case OrderStatus.dispatched:
      case OrderStatus.delivering:
        return Icon(
          Icons.local_shipping,
          size: 14,
          color: isDarkMode ? AppColors.brandAccent : AppColors.primaryColor,
        );
      case OrderStatus.completed:
        return Icon(
          Icons.check_circle,
          size: 14,
          color: isDarkMode ? Colors.green : Colors.green,
        );
      case OrderStatus.canceled:
        return Icon(
          Icons.cancel,
          size: 14,
          color: isDarkMode ? Colors.red : Colors.red,
        );
      default:
        return Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: isDarkMode ? AppColors.brandAccent : AppColors.primaryColor,
        );
    }
  }

  // Helper method to navigate based on order status
  void _navigateBasedOnStatus(BuildContext context, OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        // New order - Show details with confirm/cancel options
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
        break;

      case OrderStatus.processing:
        // Processing order - Show confirmation screen for item selection
        // Convert order items to OrderItem list for confirmation screen
        final List<OrderItem> orderItems = order.merchantOrders
            .expand((merchantOrder) => merchantOrder.items)
            .map((item) => OrderItem(
                  productId: item.productId,
                  productName: item.productName,
                  quantity: item.quantity,
                  price: item.price,
                  images: item.images,
                  measure: item.measure,
                  sku: item.sku,
                ))
            .toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(
              items: orderItems,
              orderId: order.id,
            ),
          ),
        );
        break;

      case OrderStatus.dispatched:
      case OrderStatus.delivering:
        // Dispatched or delivering order - Show tracking screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(
              orderId: order.id,
              riderId: 'riderId', // Replace with actual rider ID if available
              onCompleted: () {
                // Handle completion if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order completed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        );
        break;

      case OrderStatus.completed:
      case OrderStatus.canceled:
      default:
        // Completed or canceled order - Show details with disabled buttons
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
        break;
    }
  }

  // Helper method to map order status string to OrderStatus enum
  OrderStatus _getOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return OrderStatus.received;
      case 'processing':
      case 'pending':
        return OrderStatus.processing;
      case 'dispatched':
      case 'ready to ship':
        return OrderStatus.dispatched;
      case 'delivering':
      case 'shipping':
      case 'in progress':
      case 'out for delivery':
        return OrderStatus.delivering;
      case 'completed':
        return OrderStatus.completed;
      case 'canceled':
      case 'cancelled':
        return OrderStatus.canceled;
      default:
        return OrderStatus
            .processing; // Default to processing for unknown statuses
    }
  }
}
