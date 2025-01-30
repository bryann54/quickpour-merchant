import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:quickpourmerchant/features/notifications/data/models/notifications_model.dart';
import 'package:quickpourmerchant/features/notifications/data/repositories/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;
  StreamSubscription? _notificationsSubscription;

  NotificationsBloc(this._repository) : super(const NotificationsState()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<FetchUnreadCount>(_onFetchUnreadCount);
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<NotificationsUpdated>(_onNotificationsUpdated);
    on<StopNotificationsListening>(_onStopNotificationsListening);
  }

  // Add this new handler
  Future<void> _onInitializeNotifications(
    InitializeNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    await _repository.startListeningToOrders();

    _notificationsSubscription?.cancel();
    _notificationsSubscription = _repository.notificationsStream.listen(
      (notifications) {
        add(NotificationsUpdated(notifications));
      },
    );

    // Fetch initial notifications
    add(FetchNotifications());
  }

  // Add this new handler
  Future<void> _onStopNotificationsListening(
    StopNotificationsListening event,
    Emitter<NotificationsState> emit,
  ) async {
    await _notificationsSubscription?.cancel();
    _repository.dispose();
  }

  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final notifications = await _repository.fetchNotifications();
      final uniqueNotifications = notifications.toSet().toList();
      final unreadCount = uniqueNotifications.where((n) => !n.isRead).length;

      emit(state.copyWith(
        notifications: uniqueNotifications,
        unreadCount: unreadCount,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.markNotificationAsRead(event.notificationId);

      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == event.notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      final newUnreadCount =
          updatedNotifications.where((n) => !n.isRead).length;

      emit(state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onFetchUnreadCount(
    FetchUnreadCount event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final unreadCount = await _repository.getUnreadNotificationsCount();
      emit(state.copyWith(unreadCount: unreadCount));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onStartListening(
    StartListening event,
    Emitter<NotificationsState> emit,
  ) async {
    await _repository.startListeningToOrders();

    _notificationsSubscription?.cancel();
    _notificationsSubscription = _repository.notificationsStream.listen(
      (notifications) {
        add(NotificationsUpdated(notifications));
      },
    );
  }

  Future<void> _onStopListening(
    StopListening event,
    Emitter<NotificationsState> emit,
  ) async {
    await _notificationsSubscription?.cancel();
    _repository.dispose();
  }

  void _onNotificationsUpdated(
    NotificationsUpdated event,
    Emitter<NotificationsState> emit,
  ) {
    final unreadCount = event.notifications.where((n) => !n.isRead).length;
    emit(state.copyWith(
      notifications: event.notifications,
      unreadCount: unreadCount,
    ));
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    _repository.dispose();
    return super.close();
  }
}
