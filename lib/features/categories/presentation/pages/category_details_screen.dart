import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/categories/domain/entities/category.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/search_bar.dart';
import 'package:quickpourmerchant/features/product/data/repositories/product_repository.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_card.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailsScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  final double expandedHeight =
      300.0; 

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onFilterTap() {
    // Handle filter button functionality here
    print('Filter button tapped');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductsBloc(
        productRepository: ProductRepository(),
      )..add(FetchProducts()),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: expandedHeight,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.category.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                background: Hero(
                  tag: 'category_image_${widget.category.id}',
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.category.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Search bar section
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: CustomSearchBar(
                  controller: _searchController,
                  onSearch: _onSearch,
                  onFilterTap: _onFilterTap,
                ),
              ),
            ),
            // Search results indicator
            if (_searchQuery.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Displaying results for: $_searchQuery',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            // Products grid
            BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, state) {
                if (state is CategoriesLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }

                if (state is ProductsLoaded) {
                  final categoryProducts = state.products
                      .where((product) =>
                          product.category.toString() == widget.category.id)
                      .toList();

                  if (categoryProducts.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No products found for ${widget.category.name} category',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = categoryProducts[index];
                          return ProductCard(product: product);
                        },
                        childCount: categoryProducts.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                    ),
                  );
                }

                if (state is ProductsError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        state.message,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.red),
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }
}
