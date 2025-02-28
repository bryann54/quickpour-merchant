// requests_state.dart
import 'package:equatable/equatable.dart';
import 'package:quickpourmerchant/features/requests/data/models/drink_request_model.dart';

abstract class DrinkRequestState extends Equatable {
  const DrinkRequestState();

  @override
  List<Object?> get props => [];
}

class DrinkRequestInitial extends DrinkRequestState {}

class DrinkRequestLoading extends DrinkRequestState {}

class DrinkRequestLoaded extends DrinkRequestState {
  final List<DrinkRequest> requests;

  const DrinkRequestLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class DrinkRequestError extends DrinkRequestState {
  final String message;

  const DrinkRequestError(this.message);

  @override
  List<Object?> get props => [message];
}

class SubmittingOffer extends DrinkRequestState {}

class OfferSubmitted extends DrinkRequestState {}
