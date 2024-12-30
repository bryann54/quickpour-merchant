import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickpourmerchant/core/theme/app_theme.dart';
import 'package:quickpourmerchant/core/theme/theme_controller.dart';
import 'package:quickpourmerchant/core/utils/routes.dart';
import 'package:quickpourmerchant/features/products/presentation/pages/home_screen.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
          create: (_) => ThemeController(),
          child: Consumer<ThemeController>(
            builder: (context, themeController, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeController.themeMode,
                home: HomeScreen(),
                initialRoute: RouteGenerator.home,
            onGenerateRoute: RouteGenerator.generateRoute,
              );
            },
          ),
    );
  }
}
