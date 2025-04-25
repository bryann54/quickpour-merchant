import 'package:flutter/material.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/function_utils.dart';
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

    // Get order status enum
    final orderStatus = OrderStatusUtils().getOrderStatus(order.status);

    return InkWell(
      onTap: () => _navigateBasedOnStatus(context, orderStatus),
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
              _buildOrderHeader(theme, isDarkMode),
              const SizedBox(height: 12),
              _buildOrderIdAndPrice(theme, isDarkMode),
              const SizedBox(height: 4),
              _buildOrderDate(theme),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildCustomerInfo(theme, isDarkMode, orderStatus),
            ],
          ),
        ),
      ),
    );
  }

  // Build the order header (status badge and payment method)
  Widget _buildOrderHeader(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        _buildStatusBadge(theme, isDarkMode),
        const Spacer(),
        _buildPaymentMethod(theme),
      ],
    );
  }

  // Build the status badge
  Widget _buildStatusBadge(ThemeData theme, bool isDarkMode) {
    final statusColor = getStatusColor(order.status, isDarkMode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
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
              color: statusColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            formatStatus(order.status),
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Build the payment method section
  Widget _buildPaymentMethod(ThemeData theme) {
    return Row(
      children: [
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
    );
  }

  // Build the order ID and price section
  Widget _buildOrderIdAndPrice(ThemeData theme, bool isDarkMode) {
    return Row(
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
            'Ksh ${formatMoney(order.total)}',
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
    );
  }

  // Build the order date section
  Widget _buildOrderDate(ThemeData theme) {
    return Text(
      DateFormat('MMM d, yyyy • h:mm a').format(order.date),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.hintColor,
      ),
    );
  }

  // Build the customer info section
  Widget _buildCustomerInfo(
      ThemeData theme, bool isDarkMode, OrderStatus status) {
    return Row(
      children: [
        _buildCustomerAvatar(isDarkMode),
        const SizedBox(width: 12),
        _buildCustomerDetails(theme),
        const Spacer(),
        _buildActionButton(isDarkMode, status),
      ],
    );
  }

  // Build the customer avatar
  Widget _buildCustomerAvatar(bool isDarkMode) {
    return Hero(
      tag: 'customer-avatar-${order.id}',
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isDarkMode
            ? AppColors.brandAccent.withOpacity(0.2)
            : AppColors.primaryColor.withOpacity(0.1),
        child: Text(
          order.userName.isNotEmpty ? order.userName[0].toUpperCase() : '?',
          style: TextStyle(
            color: isDarkMode ? AppColors.brandAccent : AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Build the customer details section
  Widget _buildCustomerDetails(ThemeData theme) {
    return Expanded(
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
                _getDeliveryTypeIcon(order.deliveryType),
                size: 14,
                color: _getDeliveryTypeColor(order.deliveryType),
              ),
              const SizedBox(width: 4),
              Text(
                order.deliveryType,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getDeliveryTypeColor(order.deliveryType),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build the action button based on status
  Widget _buildActionButton(bool isDarkMode, OrderStatus status) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.brandAccent.withOpacity(0.15)
            : AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(
        OrderStatusUtils.getStatusIcon(status),
        size: 14,
        color: isDarkMode ? AppColors.brandAccent : AppColors.primaryColor,
      ),
    );
  }

  // Helper method to get delivery type icon
  IconData _getDeliveryTypeIcon(String deliveryType) {
    if (deliveryType.toLowerCase().contains('express')) {
      return Icons.rocket_launch;
    } else if (deliveryType.toLowerCase().contains('standard')) {
      return Icons.local_shipping;
    } else {
      return Icons.store;
    }
  }

  // Helper method to get delivery type color
  Color _getDeliveryTypeColor(String deliveryType) {
    if (deliveryType.toLowerCase().contains('express')) {
      return Colors.orange;
    } else if (deliveryType.toLowerCase().contains('standard')) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  // Helper method to navigate based on order status
  void _navigateBasedOnStatus(BuildContext context, OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
        break;
      case OrderStatus.processing:
        final orderItems = order.merchantOrders
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(
              orderId: order.id,
              riderId: 'riderId',
              onCompleted: () {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
        break;
    }
  }
}
