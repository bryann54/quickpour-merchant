
import 'package:quickpourmerchant/features/orders/data/models/order_model.dart';

class CompletedOrder {
  final String id;
  final DateTime date;
  final double total;
  final String? address;
  final String? phoneNumber;
  final String paymentMethod;
  final String userName;
  final String userEmail;
  final String status;
  final String? specialInstructions;
  final String deliveryTime;
  final List<OrderItem> items;

  CompletedOrder({
    required this.id,
    required this.date,
    required this.total,
    this.address,
    this.phoneNumber,
    required this.paymentMethod,
    required this.userName,
    required this.userEmail,
    required this.status,
    this.specialInstructions,
    required this.deliveryTime,
    required this.items,
  });

  // Factory constructor to handle JSON deserialization
  factory CompletedOrder.fromJson(Map<String, dynamic> json) {
    return CompletedOrder(
      id: json['orderId'] as String,
      date: DateTime.parse(json['date'] as String),
      total: (json['totalAmount'] as num).toDouble(),
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      paymentMethod: json['paymentMethod'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      status: json['status'] as String,
      specialInstructions: json['specialInstructions'] as String?,
      deliveryTime: json['deliveryTime'] as String,
      items: (json['cartItems'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
