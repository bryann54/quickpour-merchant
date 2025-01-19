import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/custom_appbar.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_event.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';
import 'package:quickpourmerchant/features/categories/presentation/pages/categories_screen.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/horizontal_list_widget.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/shimmer_widget.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/orders_screen.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductsBloc>().add(FetchProducts());
          context.read<CategoriesBloc>().add(LoadCategories());
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 200.0,
              leading: IconButton(
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
                        height: 240),
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
                  OrdersScreen(),
                  RequestsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFAB(),
    );
  }

  Widget _buildHomeContent(
      BuildContext context, ThemeData theme, bool isDarkMode) {
    return ListView(
      children: [
        _buildCategoriesSection(context, theme, isDarkMode),
        const SizedBox(height: 16),
        _buildProductsSection(theme),
      ],
    );
  }

  Widget _buildCategoriesSection(
      BuildContext context, ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, right: 3, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Categories',
                style: GoogleFonts.montaga(
                  textStyle: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'See All',
                  style: GoogleFonts.montaga(
                    textStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? Colors.white : AppColors.accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoaded) {
              return HorizontalCategoriesListWidget(
                  categories: state.categories);
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
                  : _buildProductsGrid(state.products);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      padding: const EdgeInsets.all(10),
      itemBuilder: (_, __) => const ProductCardShimmer(),
    );
  }

  Widget _buildProductsGrid(List<MerchantProductModel> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) => ProductCard(product: products[index]),
    );
  }
}
