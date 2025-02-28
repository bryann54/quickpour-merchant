// requests_event.dart
import 'package:equatable/equatable.dart';
import 'package:quickpourmerchant/features/requests/data/models/drink_request_model.dart';

abstract class DrinkRequestEvent extends Equatable {
  const DrinkRequestEvent();

  @override
  List<Object?> get props => [];
}

class LoadDrinkRequests extends DrinkRequestEvent {}

class UpdateDrinkRequests extends DrinkRequestEvent {
  final List<DrinkRequest> requests;

  const UpdateDrinkRequests(this.requests);

  @override
  List<Object?> get props => [requests];
}

class AddDrinkRequest extends DrinkRequestEvent {
  final DrinkRequest request;

  const AddDrinkRequest(this.request);
}

class SubmitOffer extends DrinkRequestEvent {
  final String requestId;
  final double price;
  final DateTime deliveryTime;
  final String? notes;
  final String storeName;
  final String location;

  const SubmitOffer({
    required this.requestId,
    required this.price,
    required this.deliveryTime,
    this.notes,
    required this.storeName,
    required this.location,
  });

  @override
  List<Object?> get props =>
      [requestId, price, deliveryTime, notes, storeName, location];
}
