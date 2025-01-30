part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class FetchNotifications extends NotificationsEvent {}

class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class FetchUnreadCount extends NotificationsEvent {}

class StartListening extends NotificationsEvent {}

class StopListening extends NotificationsEvent {}

class NotificationsUpdated extends NotificationsEvent {
  final List<NotificationModel> notifications;

  const NotificationsUpdated(this.notifications);

  @override
  List<Object> get props => [notifications];
}

class InitializeNotifications extends NotificationsEvent {
  const InitializeNotifications();
}

class StopNotificationsListening extends NotificationsEvent {
  const StopNotificationsListening();
}
