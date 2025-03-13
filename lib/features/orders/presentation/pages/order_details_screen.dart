import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/date_formatter.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';
import 'package:quickpourmerchant/features/orders/data/models/order_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/cancel_button.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/confirm_order_button.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/merchant_order_section.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/order_total_row.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/section_widget.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/order_tracking_screen.dart'; // Import the tracking screen

class OrderDetailsScreen extends StatelessWidget {
  final CompletedOrder order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
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

    // Check if order status prevents actions
    final bool isOrderCancelled = order.status == 'Canceled';
    final bool isOrderConfirmed = order.status == 'processing' ||
        order.status == 'Completed' ||
        order.status == 'In Progress' ||
        order.status == 'Out for Delivery';
    final bool canTakeAction = !isOrderCancelled && !isOrderConfirmed;

    // Determine the order status color and icon
    final OrderStatus orderStatus = _getOrderStatus(order.status);
    final Color statusColor = OrderStatusUtils.getStatusColor(orderStatus);
    final IconData statusIcon = OrderStatusUtils.getStatusIcon(orderStatus);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.4),
                    ]
                  : [
                      AppColors.primaryColor,
                      AppColors.primaryColor,
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
                backgroundColor: isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.4),
                child: Text(
                  order.userName.isNotEmpty
                      ? order.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
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
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Display current order status with color and icon
                  Row(
                    children: [
                      Icon(statusIcon, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Status: ${OrderStatusUtils.getStatusLabel(orderStatus)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
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
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.3),
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
      ),
      body: Column(
        children: [
          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderInfoCard(context, formattedDate, formattedTime),
                  const SizedBox(height: 5),
                  // Order Items
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: 'Items'),
                        if (order.merchantOrders.isNotEmpty) ...[
                          ...order.merchantOrders.map((merchantOrder) =>
                              MerchantOrderSection(
                                  merchantOrder: merchantOrder)),
                        ],
                        OrderTotalRow(order: order),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildCustomerInfoCard(context),
                  if (!canTakeAction)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isOrderCancelled
                                ? Colors.red.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isOrderCancelled
                                ? 'This order has been cancelled'
                                : 'This order has been confirmed',
                            style: TextStyle(
                              color:
                                  isOrderCancelled ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Fixed footer with buttons - conditionally show based on status
          if (canTakeAction)
            SafeArea(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Cancel Order Button
                    Expanded(
                      flex: 1,
                      child: CancelOrderButton(
                        orderId: order.id,
                        onCancelled: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order cancelled successfully'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          Navigator.pop(context); // Go back after cancellation
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // If buttons are disabled, show a note at the bottom
          if (!canTakeAction)
            SafeArea(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (isOrderConfirmed) {
                      // Navigate to the tracking screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTrackingScreen(
                            orderId: order.id,
                            riderId: 'riderId', // Replace with actual rider ID
                            onCompleted: () {
                              // Handle completion if needed
                            },
                          ),
                        ),
                      );
                    } else {
                      // Go back to orders
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isOrderConfirmed ? 'Track Order' : 'Back to Orders',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(BuildContext context, String date, String time) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
                context, 'Date & Time', '$date at $time', Icons.access_time),
            const Divider(height: 10),
            _buildInfoSection(
                context, 'Payment Method', order.paymentMethod, Icons.payment),
            const Divider(height: 10),
            _buildInfoSection(
                context, 'Status', order.status, Icons.info_outline),
            if (order.deliveryFee != 0) const Divider(height: 10),
            if (order.deliveryFee != 0)
              _buildInfoSection(context, 'Delivery Fee',
                  'Ksh ${formatMoney(order.deliveryFee)}', Icons.money),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
            ),
            const Divider(height: 10),
            _buildInfoSection(
                context, 'Phone', order.phoneNumber, Icons.phone_outlined),
            const Divider(height: 10),
            _buildInfoSection(context, 'Delivery Type', order.deliveryType,
                Icons.local_shipping_outlined),
            const Divider(height: 10),
            _buildInfoSection(context, 'Delivery Address', order.address,
                Icons.location_on_outlined),
            const Divider(height: 10),
            _buildInfoSection(context, 'Delivery Time', order.deliveryTime,
                Icons.access_time_outlined),
            if (order.specialInstructions.isNotEmpty) ...[
              const Divider(height: 10),
              _buildInfoSection(context, 'Special Instructions',
                  order.specialInstructions, Icons.notes_outlined),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      BuildContext context, String title, String value, IconData icon) {
    return Row(
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

  // Helper method to map order status string to OrderStatus enum
  OrderStatus _getOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return OrderStatus.received;
      case 'processing':
        return OrderStatus.processing;
      case 'dispatched':
        return OrderStatus.dispatched;
      case 'delivering':
        return OrderStatus.delivering;
      case 'completed':
        return OrderStatus.completed;
      case 'canceled':
        return OrderStatus.canceled;
      default:
        return OrderStatus.received;
    }
  }
}
