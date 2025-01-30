import 'package:quickpourmerchant/features/requests/data/models/drink_request_model.dart';

abstract class DrinkRequestEvent {}

class LoadDrinkRequests extends DrinkRequestEvent {}

class AddDrinkRequest extends DrinkRequestEvent {
  final DrinkRequest request;

  AddDrinkRequest(this.request);
}

class UpdateDrinkRequests extends DrinkRequestEvent {
  final List<DrinkRequest> requests;

  UpdateDrinkRequests(this.requests);
}

class SubmitOffer extends DrinkRequestEvent {
  final String requestId;
  final double price;
  final DateTime deliveryTime;
  final String? notes;
  final String storeName;
  final String location;

  SubmitOffer({
    required this.requestId,
    required this.price,
    required this.deliveryTime,
    this.notes,
    required this.storeName,
    required this.location,
  });
}

class LoadOffers extends DrinkRequestEvent {
  final String requestId;

  LoadOffers(this.requestId);
}

class UpdateOffers extends DrinkRequestEvent {
  final List<Map<String, dynamic>> offers;

  UpdateOffers(this.offers);
}
