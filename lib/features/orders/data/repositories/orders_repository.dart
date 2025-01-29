import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';
import 'package:quickpourmerchant/features/orders/data/models/order_model.dart';

class OrdersRepository {
  final FirebaseFirestore _firestore;

  OrdersRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream of orders
  Stream<List<CompletedOrder>> streamOrders() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CompletedOrder(
          id: data['orderId'] ?? '',
          date:
              DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
          total: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
          address: data['address'] as String?,
          phoneNumber: data['phoneNumber'] as String?,
          paymentMethod: data['paymentMethod'] ?? '',
          items: (data['cartItems'] as List<dynamic>)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList(),
          deliveryTime: data['deliveryTime'] ?? '',
          specialInstructions: data['specialInstructions'] ?? '',
          status: data['status'] ?? '',
          userEmail: data['userEmail'] ?? '',
          userName: data['userName'] ?? '',
        );
      }).toList();
    });
  }

  // Stream of orders count
  Stream<int> streamOrdersCount() {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Stream of feedback count (orders with non-null IDs)
  Stream<int> streamFeedbackCount() {
    return _firestore.collection('orders').snapshots().map((snapshot) =>
        snapshot.docs.where((doc) => doc.data()['orderId'] != null).length);
  }

  Future<CompletedOrder?> getOrderById(String id) async {
    final doc = await _firestore.collection('orders').doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return CompletedOrder.fromJson(data);
  }

  // One-time fetch for orders count
  Future<int> fetchOrdersCount() async {
    final snapshot = await _firestore.collection('orders').get();
    return snapshot.docs.length;
  }

  // One-time fetch for feedback count
  Future<int> fetchFeedbackCount() async {
    final snapshot = await _firestore.collection('orders').get();
    return snapshot.docs.where((doc) => doc.data()['orderId'] != null).length;
  }
}
