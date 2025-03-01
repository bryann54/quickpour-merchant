import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/date_formatter.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/confirm_order_button.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/merchant_order_section.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/order_total_row.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/section_widget.dart';

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
  // leading: IconButton(
  //   icon: Container(
  //     padding: const EdgeInsets.all(8),
  //     decoration: BoxDecoration(
  //       color: isDarkMode
  //           ? Colors.white.withOpacity(0.1)
  //           : Colors.white.withOpacity(0.3),
  //       shape: BoxShape.circle,
  //     ),
  //     child: Icon(
  //       Icons.arrow_back,
  //       color: isDarkMode ? Colors.white : Colors.white,
  //       size: 20,
  //     ),
  //   ),
  //   onPressed: () => Navigator.pop(context),
  // ),
  title: Row(
    children: [
      Hero(
       tag:
                   'customer-avatar-${order.id}',
        child: CircleAvatar(
          radius: 20,
          backgroundColor: isDarkMode
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.4),
          child: Text(
            order.userName.isNotEmpty ? order.userName[0].toUpperCase() : '?',
            style: TextStyle(
           
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              overflow: TextOverflow.ellipsis,
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
        icon: Icon(
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
      body: SingleChildScrollView(
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
                        MerchantOrderSection(merchantOrder: merchantOrder)),
                  ],
                  OrderTotalRow(order: order),
                ],
              ),
            ),
            const SizedBox(height: 5),
            _buildCustomerInfoCard(context),

            const ConfirmOrderButton(),
           
          ],
        ),
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
                if(order.deliveryFee!=0)
            const Divider(height: 10),
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
              if (order.specialInstructions.isNotEmpty)
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
}
