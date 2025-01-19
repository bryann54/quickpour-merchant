import 'package:quickpourmerchant/features/requests/data/models/drink_request_model.dart';

abstract class DrinkRequestState {}

class DrinkRequestInitial extends DrinkRequestState {}

class DrinkRequestLoading extends DrinkRequestState {}

class DrinkRequestLoaded extends DrinkRequestState {
  final List<DrinkRequest> requests;

  DrinkRequestLoaded(this.requests);
}

class DrinkRequestError extends DrinkRequestState {
  final String message;

  DrinkRequestError(this.message);
}
class OfferSubmitted extends DrinkRequestState {}

class OffersLoaded extends DrinkRequestState {
  final List<Map<String, dynamic>> offers;

  OffersLoaded(this.offers);
}
