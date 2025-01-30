import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickpourmerchant/features/brands/data/models/brands_model.dart';

class BrandRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BrandModel>> getBrands() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('brands').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ensure the document ID is included
        return BrandModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching brands: $e');
    }
  }

  Future<void> addBrand(BrandModel brand) async {
    try {
      // Create a new document with auto-generated ID
      DocumentReference docRef = _firestore.collection('brands').doc();

      // Update the brand model with the new ID
      final brandWithId = BrandModel(
        id: docRef.id,
        name: brand.name,
        country: brand.country,
        description: brand.description,
        logoUrl: brand.logoUrl,
      );

      // Set the data
      await docRef.set(brandWithId.toJson());
    } catch (e) {
      throw Exception('Error adding brand: $e');
    }
  }

  Future<void> updateBrand(BrandModel brand) async {
    try {
      await _firestore
          .collection('brands')
          .doc(brand.id)
          .update(brand.toJson());
    } catch (e) {
      throw Exception('Error updating brand: $e');
    }
  }

  Future<void> deleteBrand(String brandId) async {
    try {
      await _firestore.collection('brands').doc(brandId).delete();
    } catch (e) {
      throw Exception('Error deleting brand: $e');
    }
  }
}
