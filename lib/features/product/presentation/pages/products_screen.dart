import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/card-shimmer.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/custom_fab_widget.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_card.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/search/filter_bottomSheet.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/search/search_bar.dart';
import 'package:quickpourmerchant/features/product_search/presentation/bloc/product_search_bloc.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    final String? merchantId = _auth.currentUser?.uid;
    if (merchantId != null) {
      context.read<ProductsBloc>().add(FetchProducts());
    }
  }

  void _onSearch(String query) {
    setState(() {});
  }

  void _onFilterTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => FilterBottomSheet(
          onApplyFilters: (filters) {
            // Only access ProductSearchBloc if it's available in the widget tree
            try {
              context.read<ProductSearchBloc>().add(
                    FilterProductsEvent(
                      category: filters['category'] as String?,
                      store: filters['store'] as String?,
                      priceRange: filters['priceRange'] as RangeValues?,
                    ),
                  );
            } catch (e) {
              // Handle case where ProductSearchBloc is not available
              print('ProductSearchBloc not available: $e');
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductsBloc>().add(FetchProducts());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Your Products',
                    style: GoogleFonts.montaga(
                      textStyle: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomSearchBar(
                controller: _searchController,
                onSearch: _onSearch,
                onFilterTap: _onFilterTap,
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 50,
                                ),
                                Text(
                                  'You have no products yet...',
                                  style: GoogleFonts.montaga(
                                    textStyle: theme.textTheme.titleMedium
                                        ?.copyWith(
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
            ),
          ],
        ),
      ),
      floatingActionButton: const CustomFAB(),
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
