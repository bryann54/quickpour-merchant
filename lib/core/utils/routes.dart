import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';
import 'package:quickpourmerchant/features/auth/presentation/pages/entry_splash.dart';
import 'package:quickpourmerchant/features/auth/presentation/pages/login_screen.dart';
import 'package:quickpourmerchant/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:quickpourmerchant/features/product/presentation/pages/products_screen.dart';
import 'package:quickpourmerchant/features/profile/presentation/pages/profile_screen.dart';
import 'package:quickpourmerchant/features/profile/presentation/pages/settings_screen.dart';
import 'package:quickpourmerchant/features/promotions/presentation/pages/promotion_screen.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/orders_screen.dart';

class RouteGenerator {
  static const String home = '/home';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String analytics = '/analytics';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String promotions = '/promotions';
  static const String settings = '/settings';
  static const String login = '/login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final authUseCases = AuthUseCases(authRepository: AuthRepository());

    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const EntrySplashScreen());

      case analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case promotions:
        return MaterialPageRoute(
            builder: (_) => const MerchantPromotionsScreen());

      case profile:
        return MaterialPageRoute(
            builder: (_) => ProfileScreen(
                  authUseCases: authUseCases,
                ));

      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());

      case products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());

      case RouteGenerator.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Route Not Found'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No route defined for:',
                    style: Theme.of(_).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${settings.name}',
                    style: Theme.of(_).textTheme.headlineSmall?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(
                        Navigator.of(_).context, home),
                    icon: const Icon(Icons.home),
                    label: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
