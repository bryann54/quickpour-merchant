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

  SignupEvent(
      {required this.email,
      required this.password,
      required this.fullName,
      required this.storeName});

  @override
  List<Object?> get props => [email, password, fullName, storeName];
}

class LogoutEvent extends AuthEvent {}
