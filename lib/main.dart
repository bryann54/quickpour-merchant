import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickpourmerchant/app.dart';
import 'package:quickpourmerchant/features/notifications/domain/usecases/local_notification_service.dart';
import 'package:quickpourmerchant/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Set up the method channel for Google Maps
  const platform = MethodChannel('com.yourapp.maps');
  try {
    final String apiKey = Platform.isIOS
        ? dotenv.env['GOOGLE_MAPS_API_KEY_IOS'] ?? ''
        : dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'] ?? '';

    if (apiKey.isEmpty) {
    } else {
      await platform.invokeMethod('setApiKey', {
        'apiKey': apiKey,
      });
    }
  } catch (e) {
    debugPrint('Failed to set API key: $e');
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize NotificationService with repository
  final localNotificationService = LocalNotificationService();
  await localNotificationService.initialize();

  runApp(MyApp(notificationService: localNotificationService));
}
