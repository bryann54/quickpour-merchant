import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/requests/data/repositories/drink_request_repo.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_event.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_state.dart';

class DrinkRequestBloc extends Bloc<DrinkRequestEvent, DrinkRequestState> {
  final DrinkRequestRepository _repository;
  StreamSubscription? _requestsSubscription;

  DrinkRequestBloc({required DrinkRequestRepository repository})
      : _repository = repository,
        super(DrinkRequestInitial()) {
    on<LoadDrinkRequests>(_onLoadDrinkRequests);
    on<UpdateDrinkRequests>(_onUpdateDrinkRequests);
  }

  void _onLoadDrinkRequests(
    LoadDrinkRequests event,
    Emitter<DrinkRequestState> emit,
  ) {
    emit(DrinkRequestLoading()); // Emit loading state
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

  @override
  Future<void> close() {
    _requestsSubscription?.cancel();
    return super.close();
  }
}
