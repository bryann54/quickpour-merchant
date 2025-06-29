import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/custom_appbar.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_event.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';
import 'package:quickpourmerchant/features/categories/presentation/pages/categories_screen.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/horizontal_list_widget.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/shimmer_widget.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/order_content_widget.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/pages/products_screen.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/card-shimmer.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/custom_fab_widget.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_card.dart';
import 'package:quickpourmerchant/features/requests/presentation/pages/requests_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthUseCases _authUseCases =
      AuthUseCases(authRepository: AuthRepository());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    final String? merchantId = _auth.currentUser?.uid;
    if (merchantId != null) {
      context.read<ProductsBloc>().add(FetchProducts());
    }
    context.read<CategoriesBloc>().add(LoadCategories());
  }

  void _handleLogout() async {
    await _authUseCases.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: FirebaseDrawer(
        authUseCases: _authUseCases,
        onLogout: _handleLogout,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductsBloc>().add(FetchProducts());
          context.read<CategoriesBloc>().add(LoadCategories());
          // Also refresh orders when on orders tab
          if (_tabController.index == 1) {
            context.read<OrdersBloc>().add(StartOrdersStream());
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 120.0,
              leading: IconButton(
                color: Colors.white,
                iconSize: 30,
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primaryColor,
                  child: Center(
                    child: Image.asset('assets/111.png',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: 200),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Home'),
                  Tab(text: 'Orders'),
                  Tab(text: 'Requests'),
                ],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHomeContent(context, theme, isDarkMode),
                  _buildOrdersContent(),
                  const RequestsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const CustomFAB(),
    );
  }

  Widget _buildHomeContent(
      BuildContext context, ThemeData theme, bool isDarkMode) {
    return ListView(
      children: [
        _buildCategoriesSection(context, theme, isDarkMode),
        _buildProductsSection(theme),
      ],
    );
  }

  Widget _buildOrdersContent() {
    return BlocProvider(
      create: (_) => OrdersBloc()..add(StartOrdersStream()),
      child: const OrdersContentWidget(
        statusFilter:
            OrderStatus.pending, // Show only pending orders in home screen
        showSearchBar: false, // Hide search bar for cleaner look in home screen
      ),
    );
  }

  Widget _buildCategoriesSection(
      BuildContext context, ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, right: 3, bottom: 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Related Categories',
                style: GoogleFonts.montaga(
                  textStyle: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              BlocBuilder<CategoriesBloc, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesLoaded &&
                      state.categoriesWithProducts.length >= 6) {
                    return TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CategoriesScreen()),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'See All',
                        style: GoogleFonts.montaga(
                          textStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.accentColor,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoaded) {
              return HorizontalCategoriesListWidget(
                  categories: state.categoriesWithProducts);
            }
            return const SizedBox(
              height: 100,
              child: Center(child: LoadingHorizontalList()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Popular Products',
                style: GoogleFonts.montaga(
                  textStyle: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductsScreen()),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'See All',
                  style: GoogleFonts.montaga(
                    textStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state is ProductsLoading) {
              return _buildLoadingGrid();
            }
            if (state is ProductsError) {
              return Center(child: Text(state.message));
            }
            if (state is ProductsLoaded) {
              return state.products.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 50,
                          ),
                          Text(
                            'You have no products yet...',
                            style: GoogleFonts.montaga(
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildProductsList(state.products);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingGrid() {
return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: 6,
      itemBuilder: (_, __) => Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Image placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),

              const SizedBox(width: 12),

              // Content placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 14,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildProductsList(List<MerchantProductModel> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: products.length,
      itemBuilder: (_, index) =>
          ProductCard(product: products[index]),
    );
  }
}
