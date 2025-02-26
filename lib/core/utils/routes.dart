import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';
import 'package:quickpourmerchant/features/auth/presentation/pages/entry_splash.dart';
import 'package:quickpourmerchant/features/auth/presentation/pages/login_screen.dart';
import 'package:quickpourmerchant/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:quickpourmerchant/features/profile/presentation/pages/profile_screen.dart';
import 'package:quickpourmerchant/features/promotions/presentation/pages/promotion_screen.dart';

class RouteGenerator {
  static const String home = '/home';
  static const String products = '/products';
  //   static const String requests = '/requests';
  // static const String orders = '/orders';
  static const String analytics = '/analytics';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String promotions = '/promotions';
  static const String login = '/login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Initialize the AuthUseCases inside the static method
    final authUseCases = AuthUseCases(authRepository: AuthRepository());

    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const EntrySplashScreen());
      
      case analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
        case promotions:
        return MaterialPageRoute(builder: (_) => MerchantPromotionsScreen());
      case profile:
        return MaterialPageRoute(
            builder: (_) => ProfileScreen(
                  authUseCases: authUseCases,
                ));
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
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
