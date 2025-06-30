import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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

// Helper method to create gradient text
class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const GradientText({
    required this.text,
    this.fontSize = 17,
    this.fontWeight = FontWeight.w600,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFE74C3C),
          Color(0xFFF39C12),
        ],
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.acme(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
        ),
      ),
    );
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

enum OrderStatus {
  received,
  processing,
  dispatched,
  delivering,
  completed,
  canceled,
}

class OrderStatusUtils {
  static Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.canceled:
        return const Color.fromARGB(255, 15, 5, 68);
      case OrderStatus.received:
        return const Color(0xFFF39C12);
      case OrderStatus.processing:
        return const Color(0xFF3498DB);
      case OrderStatus.dispatched:
        return const Color(0xFF9B59B6);
      case OrderStatus.delivering:
        return const Color(0xFF1ABC9C);
      case OrderStatus.completed:
        return const Color(0xFF2ECC71);
    }
  }

  OrderStatus getOrderStatus(String status) {
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
      default:
        return OrderStatus.received;
    }
  }

  static IconData getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return Icons.assignment;
      case OrderStatus.processing:
        return Icons.build;
      case OrderStatus.dispatched:
        return FontAwesomeIcons.box;
      case OrderStatus.delivering:
        return Icons.local_shipping;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.canceled:
        return Icons.cancel;
    }
  }

  static String getStatusLabel(OrderStatus status) {
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
}
