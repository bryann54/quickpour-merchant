import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickpourmerchant/features/notifications/domain/usecases/local_notification_service.dart';
import 'package:quickpourmerchant/features/requests/data/models/drink_request_model.dart';

class DrinkRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();
  StreamSubscription? _drinkRequestsStreamSubscription;

  String? get currentMerchantId => _auth.currentUser?.uid;

  Future<void> initialize() async {
    await _localNotificationService.initialize();
    listenForNewDrinkRequests();
  }

  Future<List<DrinkRequest>> getDrinkRequests() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('drinkRequests')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map(
              (doc) => DrinkRequest.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch drink requests: $e');
    }
  }

  Stream<List<DrinkRequest>> streamDrinkRequests() {
    return _firestore
        .collection('drinkRequests')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DrinkRequest.fromMap(doc.data()))
            .toList());
  }

  void listenForNewDrinkRequests() {
    final merchantId = currentMerchantId;
    if (merchantId == null) return;

    _drinkRequestsStreamSubscription?.cancel();
    _drinkRequestsStreamSubscription = _firestore
        .collection('drinkRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _handleNewDrinkRequest(data, change.doc.id);
        }
      }
    });
  }

  Future<void> _handleNewDrinkRequest(
      Map<String, dynamic> data, String requestId) async {
    const title = 'New Drink Request';
    final body =
        'Request #${requestId.substring(0, 8)} - ${data['drinkName'] ?? 'Unknown Drink'}';

    await _localNotificationService.showNotification(
      id: requestId.hashCode,
      title: title,
      body: body,
    );
  }

  Future<List<Map<String, dynamic>>> getOffers(String requestId) async {
    try {
      // Fetch from nested 'offers' collection
      final QuerySnapshot snapshot = await _firestore
          .collection('drinkRequests')
          .doc(requestId)
          .collection('offers')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch offers: $e');
    }
  }

  Future<void> submitOffer({
    required String requestId,
    required double price,
    required DateTime deliveryTime,
    String? notes,
    required String storeName, // Add storeName
    required String location,
  }) async {
    try {
      // Use subcollection under 'drinkRequests'
      final offerId = _firestore
          .collection('drinkRequests')
          .doc(requestId)
          .collection('offers')
          .doc()
          .id;

      await _firestore
          .collection('drinkRequests')
          .doc(requestId)
          .collection('offers')
          .doc(offerId)
          .set({
        'offerId': offerId,
        'price': price,
        'deliveryTime': deliveryTime.toIso8601String(),
        'notes': notes ?? '',
        'timestamp': DateTime.now().toIso8601String(),
        'storeName': storeName, // Store name from the User model
        'location': location,
      });
    } catch (e) {
      throw Exception('Failed to submit offer: $e');
    }
  }

  void dispose() {
    _drinkRequestsStreamSubscription?.cancel();
  }
}
