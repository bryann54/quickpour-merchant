import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:quickpourmerchant/features/notifications/data/models/notifications_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeadingIcon(),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.body,
            style: TextStyle(
              color: notification.isRead ? Colors.grey : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(notification.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      trailing: !notification.isRead
          ? Icon(Icons.circle, color: Theme.of(context).primaryColor, size: 12)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildLeadingIcon() {
    switch (notification.type) {
      case NotificationType.order:
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.shopping_cart, color: Colors.white),
        );
      case NotificationType.promotion:
        return const CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.local_offer, color: Colors.white),
        );
      case NotificationType.delivery:
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.local_shipping, color: Colors.white),
        );
      case NotificationType.system:
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.settings, color: Colors.white),
        );
      case NotificationType.alert:
        return const CircleAvatar(
          backgroundColor: Colors.red,
          child: FaIcon(FontAwesomeIcons.circleInfo, color: Colors.white),
        );
      case NotificationType.feedback:
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: FaIcon(FontAwesomeIcons.faceSmileWink, color: Colors.white),
        );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }
}
