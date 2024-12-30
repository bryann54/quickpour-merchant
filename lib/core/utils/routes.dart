import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:quickpourmerchant/features/auth/presentation/pages/login_screen.dart';
import 'package:quickpourmerchant/features/product/presentation/pages/home_screen.dart';
import 'package:quickpourmerchant/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/orders_screen.dart';
import 'package:quickpourmerchant/features/product/presentation/pages/product_screen.dart';
import 'package:quickpourmerchant/features/profile/presentation/pages/profile_screen.dart';

class RouteGenerator {
  static const String home = '/home';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String analytics = '/analytics';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String login = '/login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case products:
        return MaterialPageRoute(builder: (_) => ProductsScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => OrdersScreen());
      case analytics:
        return MaterialPageRoute(builder: (_) => AnalyticsScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => NotificationsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
