import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickpourmerchant/features/brands/data/models/brands_model.dart';

class BrandRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BrandModel>> getBrands() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('brands').get();
      return querySnapshot.docs.map((doc) {
        return BrandModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching brands: $e');
    }
  }

  Future<void> addBrands(List<BrandModel> brands) async {
    final batch = _firestore.batch();
    for (var brand in brands) {
      final docRef = _firestore.collection('brands').doc(brand.id);
      batch.set(docRef, brand.toJson());
    }
    await batch.commit();
  }
}
