import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/function_utils.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';
import 'package:quickpourmerchant/features/orders/data/models/order_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/cancel_button.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/confirm_order_button.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/merchant_order_section.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/order_total_row.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/order_tracking_screen.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/order_confirmation_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final CompletedOrder order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Format date and time
    final DateTime dateTime = order.date;
    final String formattedDate =
        DateFormat('EEEE, MMM d, yyyy').format(dateTime);
    final String formattedTime = DateFormat('h:mm a').format(dateTime);

    // Convert order items to OrderItem list
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

    // Get order status
    final OrderStatus orderStatus = _getOrderStatus(order.status);
    final String statusLabel = _getStatusLabel(orderStatus);
    final Color statusColor = _getStatusColor(orderStatus, isDarkMode);
    final IconData statusIcon = _getStatusIcon(orderStatus);

    // Determine action states based on order status
    final bool canCancel = orderStatus == OrderStatus.received;
    final bool canConfirm = orderStatus == OrderStatus.received;
    final bool canTrack = orderStatus == OrderStatus.dispatched ||
        orderStatus == OrderStatus.delivering;
    final bool isCompleted = orderStatus == OrderStatus.completed;
    final bool isCanceled = orderStatus == OrderStatus.canceled;

    return Scaffold(
      appBar: _buildAppBar(
          context, isDarkMode, statusIcon, statusLabel, statusColor),
      body: Column(
        children: [
          // Order status indicator
          _buildStatusIndicator(context, orderStatus, statusColor),

          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderInfoCard(
                      context, formattedDate, formattedTime, isDarkMode),
                  const SizedBox(height: 16),

                  // Order Items
                  _buildOrderItemsCard(context, isDarkMode),

                  const SizedBox(height: 16),
                  _buildCustomerInfoCard(context, isDarkMode),

                  // Status message for completed/canceled orders
                  if (isCompleted || isCanceled)
                    _buildStatusMessage(context, isCompleted, isCanceled),

                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),

          // Bottom action buttons
          _buildBottomActionButtons(context, orderStatus, orderItems, canCancel,
              canConfirm, canTrack, isCompleted, isCanceled),
        ],
      ),
    );
  }

  // Build the app bar with customer info and status
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode,
      IconData statusIcon, String statusLabel, Color statusColor) {
    return AppBar(
      elevation: 0,
      toolbarHeight: 70,
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.4),
                  ]
                : [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withValues(alpha: 0.85),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      title: Row(
        children: [
          Hero(
            tag: 'customer-avatar-${order.id}',
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              child: Text(
                order.userName.isNotEmpty
                    ? order.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${order.userName}\'s Order',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.numbers_outlined,
                        size: 14, color: Colors.white.withValues(alpha: 0.9)),
                    const SizedBox(width: 4),
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              // Share order details functionality
            },
          ),
        ),
      ],
    );
  }

  // Build a status indicator strip below the app bar
  Widget _buildStatusIndicator(
      BuildContext context, OrderStatus status, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: statusColor.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(status),
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Status: ${_getStatusLabel(status)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
          const Spacer(),
          if (status == OrderStatus.received)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: const Text(
                'New Order',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build the order info card with date, time, payment method, etc.
  Widget _buildOrderInfoCard(
      BuildContext context, String date, String time, bool isDarkMode) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDarkMode
                      ? AppColors.brandAccent
                      : AppColors.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppColors.brandAccent
                            : AppColors.primaryColor,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoSection(
                context, 'Date & Time', '$date at $time', Icons.access_time),
            const Divider(height: 16),
            _buildInfoSection(
                context, 'Payment Method', order.paymentMethod, Icons.payment),
            const Divider(height: 16),
            _buildInfoSection(
                context,
                'Status',
                _getStatusLabel(_getOrderStatus(order.status)),
                Icons.info_outline),
            if (order.deliveryFee != 0) ...[
              const Divider(height: 16),
              _buildInfoSection(
                  context,
                  'Delivery Fee',
                  'Ksh ${formatMoney(order.deliveryFee)}',
                  Icons.local_shipping),
            ],
          ],
        ),
      ),
    );
  }

  // Build the order items card
  Widget _buildOrderItemsCard(BuildContext context, bool isDarkMode) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: isDarkMode
                      ? AppColors.brandAccent
                      : AppColors.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppColors.brandAccent
                            : AppColors.primaryColor,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (order.merchantOrders.isNotEmpty) ...[
              ...order.merchantOrders.map((merchantOrder) =>
                  MerchantOrderSection(merchantOrder: merchantOrder)),
            ],
            const Divider(height: 16),
            OrderTotalRow(order: order),
          ],
        ),
      ),
    );
  }

  // Build the customer info card
  Widget _buildCustomerInfoCard(BuildContext context, bool isDarkMode) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: isDarkMode
                      ? AppColors.brandAccent
                      : AppColors.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Customer Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppColors.brandAccent
                            : AppColors.primaryColor,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoSection(
                context, 'Phone', order.phoneNumber, Icons.phone_outlined),
            const Divider(height: 16),
            _buildInfoSection(context, 'Delivery Type', order.deliveryType,
                _getDeliveryTypeIcon(order.deliveryType)),
            const Divider(height: 16),
            _buildInfoSection(context, 'Delivery Address', order.address,
                Icons.location_on_outlined),
            const Divider(height: 16),
            _buildInfoSection(context, 'Delivery Time', order.deliveryTime,
                Icons.access_time_outlined),
            if (order.specialInstructions.isNotEmpty) ...[
              const Divider(height: 16),
              _buildInfoSection(context, 'Special Instructions',
                  order.specialInstructions, Icons.notes_outlined),
            ],
          ],
        ),
      ),
    );
  }

  // Build a status message for completed/canceled orders
  Widget _buildStatusMessage(
      BuildContext context, bool isCompleted, bool isCanceled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.cancel,
                color: isCompleted ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                isCompleted
                    ? 'Order completed successfully'
                    : 'This order has been canceled',
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the bottom action buttons based on order status
  Widget _buildBottomActionButtons(
      BuildContext context,
      OrderStatus status,
      List<OrderItem> orderItems,
      bool canCancel,
      bool canConfirm,
      bool canTrack,
      bool isCompleted,
      bool isCanceled) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // For received orders - show cancel and confirm buttons
            if (canCancel && canConfirm)
              Row(
                children: [
                  // Cancel Order Button
                  Expanded(
                    flex: 1,
                    child: CancelOrderButton(
                      orderId: order.id,
                      onCancelled: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order canceled successfully'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confirm Order Button
                  Expanded(
                    flex: 2,
                    child: ConfirmOrderButton(
                      items: orderItems,
                      orderId: order.id,
                      onConfirmed: () {
                        // Navigate to order confirmation screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderConfirmationScreen(
                              items: orderItems,
                              orderId: order.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            // For processing orders - show process items button
            if (status == OrderStatus.processing)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderConfirmationScreen(
                        items: orderItems,
                        orderId: order.id,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Process Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

            // For dispatched/delivering orders - show track order button
            if (canTrack)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingScreen(
                        orderId: order.id,
                        riderId: 'riderId', // Replace with actual rider ID
                        onCompleted: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order completed successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_shipping, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Track Order',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            // For completed/canceled orders - show back to orders button
            if (isCompleted || isCanceled)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.arrow_back,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Back to Orders',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to build info section rows
  Widget _buildInfoSection(
      BuildContext context, String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to get delivery type icon
  IconData _getDeliveryTypeIcon(String deliveryType) {
    final String type = deliveryType.toLowerCase();
    if (type.contains('express')) {
      return Icons.rocket_launch;
    } else if (type.contains('standard')) {
      return Icons.local_shipping;
    } else if (type.contains('pickup')) {
      return Icons.store;
    }
    return Icons.delivery_dining;
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
        return OrderStatus.received;
    }
  }

  // Helper method to get formatted status label
  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return 'Received';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.dispatched:
        return 'Ready to Ship';
      case OrderStatus.delivering:
        return 'Shipping';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.canceled:
        return 'Canceled';
    }
  }

  // Helper method to get status color
  Color _getStatusColor(OrderStatus status, bool isDarkMode) {
    switch (status) {
      case OrderStatus.received:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.amber;
      case OrderStatus.dispatched:
        return Colors.orange;
      case OrderStatus.delivering:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.canceled:
        return Colors.red;
    }
  }

  // Helper method to get status icon
  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return Icons.receipt_long;
      case OrderStatus.processing:
        return Icons.inventory_2;
      case OrderStatus.dispatched:
        return Icons.local_shipping;
      case OrderStatus.delivering:
        return Icons.delivery_dining;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.canceled:
        return Icons.cancel;
    }
  }
}
