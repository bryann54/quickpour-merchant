import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/requests/data/repositories/drink_request_repo.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_event.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_state.dart';

class DrinkRequestsBloc extends Bloc<DrinkRequestEvent, DrinkRequestState> {
  final DrinkRequestRepository _repository;
  StreamSubscription? _requestsSubscription;

  DrinkRequestsBloc(this._repository) : super(DrinkRequestInitial()) {
    on<LoadDrinkRequests>(_onLoadDrinkRequests);
    on<UpdateDrinkRequests>(_onUpdateDrinkRequests);
    on<SubmitOffer>(_onSubmitOffer);
  }

  void _onLoadDrinkRequests(
    LoadDrinkRequests event,
    Emitter<DrinkRequestState> emit,
  ) {
    emit(DrinkRequestLoading());
    _requestsSubscription?.cancel();
    _requestsSubscription = _repository.streamDrinkRequests().listen(
      (requests) {
        add(UpdateDrinkRequests(requests));
      },
      onError: (error) {
        emit(DrinkRequestError(error.toString()));
      },
    );
  }

  void _onUpdateDrinkRequests(
    UpdateDrinkRequests event,
    Emitter<DrinkRequestState> emit,
  ) {
    emit(DrinkRequestLoaded(event.requests));
  }

  Future<void> _onSubmitOffer(
    SubmitOffer event,
    Emitter<DrinkRequestState> emit,
  ) async {
    try {
      emit(SubmittingOffer());
      await _repository.submitOffer(
        requestId: event.requestId,
        price: event.price,
        deliveryTime: event.deliveryTime,
        notes: event.notes,
        storeName: event.storeName,
        location: event.location,
      );
      emit(OfferSubmitted());
    } catch (e) {
      emit(DrinkRequestError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _requestsSubscription?.cancel();
    return super.close();
  }
}
