import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quickpourmerchant/app.dart';
import 'package:quickpourmerchant/features/notifications/domain/usecases/local_notification_service.dart';
import 'package:quickpourmerchant/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Local Notifications
  final localNotificationService = LocalNotificationService();
  await localNotificationService.initialize();

  runApp(MyApp(notificationService: localNotificationService));
}
