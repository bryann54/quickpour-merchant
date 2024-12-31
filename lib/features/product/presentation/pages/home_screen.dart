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
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/card-shimmer.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/custom_fab_widget.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(FetchProducts());
    context.read<CategoriesBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        title: const GradientText(text: 'QuickPour Merchant'),
      ),
      drawer: CustomDrawer(
        merchantName: 'QuickPour Merchant',
        onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductsBloc>().add(FetchProducts());
          context.read<CategoriesBloc>().add(LoadCategories());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoriesSection(context, theme, isDarkMode),
                const SizedBox(height: 16),
                _buildProductsSection(theme),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: CustomFAB(
        
      ),
    );
  }

  Widget _buildCategoriesSection(
      BuildContext context, ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, top: 2, bottom: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: GoogleFonts.montaga(
                  textStyle: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                ),
                child: Text(
                  'See All',
                  style: GoogleFonts.montaga(
                    textStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? Colors.teal : AppColors.accentColor,
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
            return const Center(child: LoadingHorizontalList());
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
          child: Text(
            'Products',
            style: GoogleFonts.montaga(
              textStyle: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  ? const Center(
                      child: Text('No products available'),
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

  Widget _buildProductsGrid(List<ProductModel> products) {
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
