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
                DrinkRequest.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addDrinkRequest(DrinkRequest request) async {
    try {
      await _firestore
          .collection('drinkRequests')
          .doc(request.id)
          .set(request.toMap());
    } catch (e) {
      throw Exception('Failed to add drink request: $e');
    }
  }
}
