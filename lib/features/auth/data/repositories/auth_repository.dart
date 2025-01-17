import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickpourmerchant/core/utils/time_range_utils.dart';
import 'package:quickpourmerchant/features/auth/data/models/user_model.dart';

class AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required String storeName,
    required String location,
    required Map<String, dynamic> storeHours,
    String imageUrl = '',
  }) async {
    try {
      firebase_auth.UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user?.uid ?? '';

      // Create merchant data
      final merchantData = {
        'id': uid,
        'email': email,
        'name': fullName,
        'storeName': storeName,
        'location': location,
        'products': [],
        'experience': 0,
        'imageUrl': imageUrl,
        'rating': 0.0,
        'isVerified': false,
        'isOpen': StoreHours.fromJson(storeHours).isCurrentlyOpen(),
        'storeHours': storeHours,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Store in merchants collection instead of users
      await _firestore.collection('merchants').doc(uid).set(merchantData);

      return userCredential.user?.email ?? '';
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Your existing error handling
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred during registration: $e');
    }
  }

  //login
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify that the user exists in the merchants collection
      final uid = userCredential.user?.uid;
      if (uid != null) {
        final merchantDoc =
            await _firestore.collection('merchants').doc(uid).get();
        if (!merchantDoc.exists) {
          throw Exception('No merchant account found for this email.');
        }
      }

      return userCredential.user?.email ?? '';
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'wrong-password':
          throw Exception('Incorrect password.');
        case 'user-disabled':
          throw Exception('This user account has been disabled.');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred during login: $e');
    }
  }

  // Logout the current user
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Update getCurrentUserDetails to fetch from merchants collection
  Future<User?> getCurrentUserDetails() async {
    try {
      final firebase_auth.User? currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot merchantDoc =
            await _firestore.collection('merchants').doc(currentUser.uid).get();

        if (merchantDoc.exists) {
          final data = merchantDoc.data() as Map<String, dynamic>;
          return User.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error retrieving merchant details: $e');
    }
  }

  // Check if a user is currently signed in
  bool isUserSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Get current user's UID
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }
}
