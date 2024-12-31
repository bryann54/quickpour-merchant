import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:quickpourmerchant/core/theme/app_theme.dart';
import 'package:quickpourmerchant/core/theme/theme_controller.dart';
import 'package:quickpourmerchant/core/utils/routes.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';
import 'package:quickpourmerchant/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quickpourmerchant/features/auth/presentation/pages/entry_splash.dart';
import 'package:quickpourmerchant/features/categories/data/repositories/category_repository.dart';
import 'package:quickpourmerchant/features/categories/domain/usecases/fetch_categories.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_event.dart';
import 'package:quickpourmerchant/features/notifications/data/repositories/notifications_repository.dart';
import 'package:quickpourmerchant/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:quickpourmerchant/features/product/data/repositories/product_repository.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoriesBloc>(
          create: (context) =>
              CategoriesBloc(FetchCategories(CategoryRepository()))
                ..add(LoadCategories()),
        ),
            BlocProvider(
          create: (context) => AuthBloc(
            authUseCases: AuthUseCases(
              authRepository: AuthRepository(),
            ),
          ),
        ),
         Provider<NotificationsRepository>(
          create: (_) => NotificationsRepository(),
        ),
            BlocProvider(
          create: (context) => NotificationsBloc(
            context.read<NotificationsRepository>(),
          ),
        ),
         BlocProvider(
          create: (context) =>
              OrdersBloc()
                ..add(LoadOrdersFromCheckout()),
        ),
        BlocProvider(
        create: (context) => ProductsBloc(productRepository: ProductRepository())),
      ],
      child: ChangeNotifierProvider(
        create: (_) => ThemeController(),
        child: Consumer<ThemeController>(
          builder: (context, themeController, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeController.themeMode,
              home:  EntrySplashScreen(),
              initialRoute: RouteGenerator.home,
              onGenerateRoute: RouteGenerator.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
