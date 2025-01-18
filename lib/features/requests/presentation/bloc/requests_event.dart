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
