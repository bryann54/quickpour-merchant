import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickpourmerchant/features/categories/data/models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> uploadCategories(List<CategoryModel> categories) async {
    try {
      WriteBatch batch = _firebaseFirestore.batch();

      for (var category in categories) {
        DocumentReference categoryRef =
            _firebaseFirestore.collection('categories').doc(category.id);
        batch.set(categoryRef, category.toJson());
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _firebaseFirestore.collection('categories').get();

      List<CategoryModel> categories = querySnapshot.docs
          .map((doc) =>
              CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return categories;
    } catch (e) {
      rethrow;
    }
  }
}
