import 'package:quickpourmerchant/features/auth/data/models/user_model.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';
import 'package:quickpourmerchant/core/utils/time_range_utils.dart';

class AuthUseCases {
  final AuthRepository authRepository;

  AuthUseCases({required this.authRepository});

  Future<String> login({
    required String email,
    required String password,
  }) async {
    return await authRepository.login(
      email: email,
      password: password,
    );
  }

  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required String storeName,
    required String location,
    required StoreHours storeHours,
    String imageUrl = '',
  }) async {
    return await authRepository.register(
      email: email,
      password: password,
      fullName: fullName,
      storeName: storeName,
      location: location,
      imageUrl: imageUrl,
      storeHours: storeHours.toJson(),
    );
  }

  Future<void> logout() async {
    await authRepository.logout();
  }

  Future<User?> getCurrentUserDetails() async {
    return await authRepository.getCurrentUserDetails();
  }

  bool isUserSignedIn() {
    return authRepository.isUserSignedIn();
  }

  String? getCurrentUserId() {
    return authRepository.getCurrentUserId();
  }
}
