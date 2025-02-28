import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:quickpourmerchant/features/notifications/data/models/notifications_model.dart';
import 'package:quickpourmerchant/features/notifications/domain/usecases/local_notification_service.dart';

class NotificationsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LocalNotificationService _localNotificationService;
  StreamSubscription? _ordersSubscription;
  StreamSubscription? _drinkRequestsSubscription;

  NotificationsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    LocalNotificationService? localNotificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _localNotificationService =
            localNotificationService ?? LocalNotificationService();

  Stream<List<NotificationModel>> get notificationsStream {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationModel(
          id: doc.id,
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isRead: data['isRead'] ?? false,
          type: _getNotificationType(data['type'] ?? 'system'),
        );
      }).toList();
    });
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationModel(
          id: doc.id,
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isRead: data['isRead'] ?? false,
          type: _getNotificationType(data['type'] ?? 'system'),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> startListeningToOrders() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Listen to new orders
    _ordersSubscription = _firestore
        .collection('orders')
        .where('merchantId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final orderData = change.doc.data() as Map<String, dynamic>;
          _handleNewOrder(orderData, change.doc.id);
        }
      }
    });

    // Listen to drink requests
    _drinkRequestsSubscription = _firestore
        .collection('drinkRequests')
        .where('merchantId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final requestData = change.doc.data() as Map<String, dynamic>;
          _handleNewDrinkRequest(requestData, change.doc.id);
        }
      }
    });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<int> getUnreadNotificationsCount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to fetch unread notifications count: $e');
    }
  }

  Future<void> _handleNewOrder(
      Map<String, dynamic> orderData, String orderId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    const title = 'New Order Received';
    final body =
        'Order #${orderId.substring(0, 8)} - ${orderData['items']?.length ?? 0} items';

    // Create Firestore notification
    await createNotification(
      title: title,
      body: body,
      type: NotificationType.order,
      userId: userId,
    );

    // Show local notification
    await _localNotificationService.showNotification(
      id: orderId.hashCode,
      title: title,
      body: body,
    );
  }

  Future<void> _handleNewDrinkRequest(
      Map<String, dynamic> requestData, String requestId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    const title = 'New Drink Request';
    final body =
        'Request #${requestId.substring(0, 8)} - ${requestData['drinkName'] ?? 'Unknown Drink'}';

    // Create Firestore notification
    await createNotification(
      title: title,
      body: body,
      type: NotificationType.order,
      userId: userId,
    );

    // Show local notification
    await _localNotificationService.showNotification(
      id: requestId.hashCode,
      title: title,
      body: body,
    );
  }

  Future<void> createNotification({
    required String title,
    required String body,
    required NotificationType type,
    required String userId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'body': body,
        'type': _getNotificationTypeString(type),
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'userId': userId,
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  NotificationType _getNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return NotificationType.order;
      case 'promotion':
        return NotificationType.promotion;
      case 'delivery':
        return NotificationType.delivery;
      case 'alert':
        return NotificationType.alert;
      case 'feedback':
        return NotificationType.feedback;
      case 'system':
      default:
        return NotificationType.system;
    }
  }

  String _getNotificationTypeString(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return 'order';
      case NotificationType.promotion:
        return 'promotion';
      case NotificationType.delivery:
        return 'delivery';
      case NotificationType.system:
        return 'system';
      case NotificationType.feedback:
        return 'feedback';
      case NotificationType.alert:
        return 'alert';
    }
  }

  void dispose() {
    _ordersSubscription?.cancel();
    _drinkRequestsSubscription?.cancel();
  }
}
