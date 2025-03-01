import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickpourmerchant/features/promotions/data/models/promotion_model.dart';

String formatMoney(num amount) {
  final formatter = NumberFormat('#,##0', 'en_US');
  return formatter.format(amount);
}

String formatDate(DateTime date) {
  return '${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
}

/// Determine Promotion Target Label
String getTargetLabel(MerchantPromotionModel promotion) {
  if (promotion.productIds.isNotEmpty) {
    return '${promotion.productIds.length} Products';
  } else if (promotion.categoryIds.isNotEmpty) {
    return '${promotion.categoryIds.length} Categories';
  } else if (promotion.brandIds.isNotEmpty) {
    return '${promotion.brandIds.length} Brands';
  }
  return 'General Promotion';
}

// Format status text
String formatStatus(String status) {
  return status
      .split('_')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join(' ');
}

// Helper method to determine the icon
IconData getPaymentMethodIcon(String paymentMethod) {
  final method = paymentMethod.toLowerCase();
  if (method.contains('card')) {
    return Icons.credit_card;
  } else if (method.contains('cash') || method.contains('delivery')) {
    return Icons.handshake;
  } else {
    return Icons.money;
  }
}

// Helper function to get status color
Color getStatusColor(String status, bool isDarkMode) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'processing':
      return Colors.blue;
    case 'completed':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    default:
      return isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
  }
}
