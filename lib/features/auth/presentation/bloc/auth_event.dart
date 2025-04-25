import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignupEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String storeName;
  final String location;
  final String imageUrl;
  final Map<String, dynamic> storeHours;
  final bool is24Hours;

  SignupEvent({
    required this.email,
    required this.password,
    required this.fullName,
    required this.storeName,
    required this.location,
    required this.storeHours,
    required this.is24Hours,
    this.imageUrl = '',
  });
}
class CheckAuthStatusEvent extends AuthEvent {}
class LogoutEvent extends AuthEvent {}
