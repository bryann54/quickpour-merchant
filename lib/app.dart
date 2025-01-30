import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:quickpourmerchant/core/theme/app_theme.dart';
import 'package:quickpourmerchant/core/theme/theme_controller.dart';
import 'package:quickpourmerchant/core/utils/routes.dart';
import 'package:quickpourmerchant/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';
import 'package:quickpourmerchant/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quickpourmerchant/features/auth/presentation/pages/entry_splash.dart';
import 'package:quickpourmerchant/features/brands/data/repositories/brand_repository.dart';
import 'package:quickpourmerchant/features/brands/presentation/bloc/brands_bloc.dart';
import 'package:quickpourmerchant/features/categories/data/repositories/category_repository.dart';
import 'package:quickpourmerchant/features/categories/domain/usecases/fetch_categories.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_event.dart';
import 'package:quickpourmerchant/features/notifications/data/repositories/notifications_repository.dart';
import 'package:quickpourmerchant/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:quickpourmerchant/features/orders/data/repositories/orders_repository.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:quickpourmerchant/features/product/data/repositories/product_repository.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/requests/data/repositories/drink_request_repo.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_event.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BrandsBloc>(
          create: (context) => BrandsBloc(
            brandRepository: BrandRepository(),
          )..add(FetchBrandsEvent()),
        ),
        BlocProvider<CategoriesBloc>(
          create: (context) => CategoriesBloc(
              FetchCategories(CategoryRepository(), ProductRepository()))
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
        BlocProvider<NotificationsBloc>(
          create: (context) => NotificationsBloc(
            NotificationsRepository(),
          )..add(const InitializeNotifications()),
        ),
        BlocProvider(
          create: (context) => OrdersBloc()..add(StartOrdersStream()),
        ),
        BlocProvider(
            create: (context) => AnalyticsBloc(
                productRepository: ProductRepository(),
                ordersRepository: OrdersRepository())),
        BlocProvider(
          create: (context) => ProductsBloc(
            productRepository: ProductRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => DrinkRequestBloc(
            repository: DrinkRequestRepository(),
          )..add(LoadDrinkRequests()),
        ),
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
              home: const EntrySplashScreen(),
              initialRoute: RouteGenerator.home,
              onGenerateRoute: RouteGenerator.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
