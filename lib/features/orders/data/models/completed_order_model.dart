import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickpourmerchant/features/orders/data/models/merchant_order_item_model.dart';

class CompletedOrder {
  final String id;
  final double total;
  final DateTime date;
  final String address;
  final String phoneNumber;
  final String paymentMethod;
  final List<MerchantOrderItem> merchantOrders;
  final String userEmail;
  final String userName;
  final String userId;
  final String status;
  final String deliveryType;
  final String deliveryTime;
  final double deliveryFee;
  final String specialInstructions;

  CompletedOrder({
    required this.id,
    required this.total,
    required this.date,
    required this.address,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.merchantOrders,
    required this.userEmail,
    required this.userName,
    required this.userId,
    required this.status,
    this.deliveryType = 'No delivery type specified',
    this.deliveryTime = 'No delivery time specified',
    this.deliveryFee = 0.00, // Default value
    this.specialInstructions = '',
  });

  factory CompletedOrder.fromFirebase(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic dateData) {
      if (dateData is Timestamp) {
        return dateData.toDate();
      } else if (dateData is String) {
        return DateTime.parse(dateData);
      }
      return DateTime.now();
    }

    // Ensure deliveryFee is a valid double
    double parseDeliveryFee(dynamic feeData) {
      if (feeData == null) {
        return 0.00; // Default value if null
      }
      return (feeData as num).toDouble(); // Convert to double
    }

    return CompletedOrder(
      id: id,
      total: (data['totalAmount'] ?? 0).toDouble(),
      date: parseDate(data['date']),
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      merchantOrders: (data['merchantOrders'] as List<dynamic>?)
              ?.map((merchantData) => MerchantOrderItem.fromFirebase(
                  merchantData as Map<String, dynamic>))
              .toList() ??
          [],
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'pending',
      deliveryType: data['deliveryType'] ?? 'No delivery type specified',
      deliveryTime: data['deliveryTime'] ?? 'No delivery time specified',
      deliveryFee: parseDeliveryFee(data['deliveryFee']), // Use helper function
      specialInstructions: data['specialInstructions'] ?? '',
    );
  }

  // Get only the orders for a specific merchant
  List<MerchantOrderItem> getMerchantOrders(String merchantId) {
    return merchantOrders
        .where((order) => order.merchantId == merchantId)
        .toList();
  }

  // Get total for a specific merchant
  double getMerchantTotal(String merchantId) {
    return merchantOrders
        .where((order) => order.merchantId == merchantId)
        .fold(0, (sum, order) => sum + order.subtotal);
  }

  // Create a copy with updated fields
  CompletedOrder copyWith({
    String? id,
    double? total,
    DateTime? date,
    String? address,
    String? phoneNumber,
    String? paymentMethod,
    List<MerchantOrderItem>? merchantOrders,
    String? userEmail,
    String? userName,
    String? userId,
    String? status,
    String? deliveryType,
    String? deliveryTime,
    double? deliveryFee,
    String? specialInstructions,
  }) {
    return CompletedOrder(
      id: id ?? this.id,
      total: total ?? this.total,
      date: date ?? this.date,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      merchantOrders: merchantOrders ?? this.merchantOrders,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}
