import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/requests/data/repositories/drink_request_repo.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_event.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_state.dart';

class DrinkRequestBloc extends Bloc<DrinkRequestEvent, DrinkRequestState> {
  final DrinkRequestRepository _repository;
  StreamSubscription? _requestsSubscription;

  DrinkRequestBloc({
    required DrinkRequestRepository repository,
  })  : _repository = repository,
        super(DrinkRequestInitial()) {
    on<LoadDrinkRequests>(_onLoadDrinkRequests);
    on<AddDrinkRequest>(_onAddDrinkRequest);
    on<UpdateDrinkRequests>(_onUpdateDrinkRequests);
  }

  void _onLoadDrinkRequests(
    LoadDrinkRequests event,
    Emitter<DrinkRequestState> emit,
  ) {
    _requestsSubscription?.cancel();
    _requestsSubscription = _repository.streamDrinkRequests().listen(
      (requests) {
        add(UpdateDrinkRequests(requests));
      },
    );
  }

  Future<void> _onAddDrinkRequest(
    AddDrinkRequest event,
    Emitter<DrinkRequestState> emit,
  ) async {
    try {
      await _repository.addDrinkRequest(event.request);
    } catch (e) {
      emit(DrinkRequestError(e.toString()));
    }
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
