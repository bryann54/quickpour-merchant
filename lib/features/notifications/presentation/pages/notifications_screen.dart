// notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:quickpourmerchant/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>()
      ..add(const InitializeNotifications())
      ..add(FetchNotifications());
  }

  @override
  void dispose() {
    context.read<NotificationsBloc>().add(const StopNotificationsListening());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.error != null) {
            return Center(
              child: Text('Error: ${state.error}'),
            );
          }

          if (state.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: state.notifications.length,
            itemBuilder: (context, index) {
              final notification = state.notifications[index];
              return NotificationTile(
                notification: notification,
                onTap: () {
                  context
                      .read<NotificationsBloc>()
                      .add(MarkNotificationAsRead(notification.id));
                },
              );
            },
          );
        },
      ),
    );
  }
}
