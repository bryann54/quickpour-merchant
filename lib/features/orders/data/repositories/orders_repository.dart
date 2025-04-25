import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';

class OrdersRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrdersRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Get current merchant ID
  String? get currentMerchantId => _auth.currentUser?.uid;

  // Creates a stream of orders for the current merchant
  Stream<List<CompletedOrder>> streamOrders() {
    final merchantId = currentMerchantId;
    if (merchantId == null) {
      return Stream.error('Merchant not authenticated');
    }

    return _firestore
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      List<CompletedOrder> orders = [];
      for (var doc in snapshot.docs) {
        try {
          final order = CompletedOrder.fromFirebase(doc.data(), doc.id);

          // Filter merchantOrders to only include current merchant's orders
          final relevantMerchantOrders = order.merchantOrders
              .where((merchantOrder) => merchantOrder.merchantId == merchantId)
              .toList();

          // Only add orders that have items for this merchant
          if (relevantMerchantOrders.isNotEmpty) {
            // Create a new order with only this merchant's items
            final merchantOrder = CompletedOrder(
              id: order.id,
              total: order.total,
              date: order.date,
              address: order.address,
              phoneNumber: order.phoneNumber,
              paymentMethod: order.paymentMethod,
              merchantOrders: relevantMerchantOrders,
              userEmail: order.userEmail,
              userName: order.userName,
              userId: order.userId,
              status: order.status,
              deliveryType: order.deliveryType,
              deliveryTime: order.deliveryTime,
              specialInstructions: order.specialInstructions,
            );
            orders.add(merchantOrder);
          }
        } catch (e) {
          print('Error parsing order ${doc.id}: $e');
          continue;
        }
      }
      return orders;
    });
  }

  // In OrdersRepository class
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  // One-time fetch of orders (keep for backward compatibility)
  Future<List<CompletedOrder>> getOrders() async {
    final merchantId = currentMerchantId;
    if (merchantId == null) {
      throw Exception('Merchant not authenticated');
    }

    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .orderBy('date', descending: true)
          .get();

      List<CompletedOrder> orders = [];

      for (var doc in querySnapshot.docs) {
        try {
          final order = CompletedOrder.fromFirebase(doc.data(), doc.id);

          // Filter merchantOrders to only include current merchant's orders
          final relevantMerchantOrders = order.merchantOrders
              .where((merchantOrder) => merchantOrder.merchantId == merchantId)
              .toList();

          // Only add orders that have items for this merchant
          if (relevantMerchantOrders.isNotEmpty) {
            // Create a new order with only this merchant's items
            final merchantOrder = CompletedOrder(
              id: order.id,
              total: order.total,
              date: order.date,
              address: order.address,
              phoneNumber: order.phoneNumber,
              paymentMethod: order.paymentMethod,
              merchantOrders: relevantMerchantOrders,
              userEmail: order.userEmail,
              userName: order.userName,
              userId: order.userId,
              status: order.status,
              deliveryType: order.deliveryType,
              deliveryTime: order.deliveryTime,
              specialInstructions: order.specialInstructions,
            );
            orders.add(merchantOrder);
          }
        } catch (e) {
          print('Error parsing order ${doc.id}: $e');
          continue;
        }
      }

      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Stream orders count for the current merchant
  Stream<int> streamOrdersCount() {
    final merchantId = currentMerchantId;
    if (merchantId == null) {
      return Stream.error('Merchant not authenticated');
    }

    // This query counts orders that contain this merchant's ID in the merchantOrders array
    return _firestore
        .collection('orders')
        .where('merchantIds', arrayContains: merchantId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Stream feedback count for the current merchant
  Stream<int> streamFeedbackCount() {
    final merchantId = currentMerchantId;
    if (merchantId == null) {
      return Stream.error('Merchant not authenticated');
    }

    return _firestore
        .collection('feedback')
        .where('merchantId', isEqualTo: merchantId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
