// notifications_repository.dart

import 'package:quickpourmerchant/features/notifications/data/models/notifications_model.dart';

class NotificationsRepository {
  // Simulated notifications data source
  Future<List<NotificationModel>> fetchNotifications() async {
    // Simulating network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      NotificationModel(
        id: '1',
        title: 'New Order Received',
        body: 'You have received a new order (#5678) for 5 items.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: NotificationType.order,
      ),
      NotificationModel(
        id: '2',
        title: 'Customer Feedback',
        body:
            'A customer left a review: "Excellent service, will order again!"',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: NotificationType.feedback,
      ),
      NotificationModel(
        id: '3',
        title: 'Promotional Campaign',
        body: 'Your promotion "Happy Hour 20% Off" has started.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.promotion,
      ),
      NotificationModel(
        id: '4',
        title: 'System Update',
        body:
            'The inventory management system will be updated tonight at 12 AM.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.system,
      ),
      NotificationModel(
        id: '5',
        title: 'Low Stock Alert',
        body: 'Stock for "Margarita Mix" is running low. Please restock soon.',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        type: NotificationType.alert,
      ),
    ];
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    // Simulating API call to mark notification as read
    await Future.delayed(const Duration(milliseconds: 300));
    print('Notification $notificationId marked as read');
  }
}
