import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickpourmerchant/features/requests/data/models/drink_request_model.dart';

class DrinkRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
            .map((doc) =>
                DrinkRequest.fromMap(doc.data()))
            .toList());
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

}
