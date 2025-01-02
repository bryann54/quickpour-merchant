
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
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
         appBar: AppBar(
          title: Text('${widget.category.name} products',
            style: Theme.of(context).textTheme.displayLarge,
          ),
         ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image or category banner
       Stack(
  children: [
    Hero(
      tag: 'category_image_${widget.category.id}',
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accentColor.withOpacity(0.4)),
          image: DecorationImage(
            image: CachedNetworkImageProvider(widget.category.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3), // Darkens the image for better text visibility
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    ),
    Container( // Gradient overlay for better text visibility
      width: double.infinity,
      height: 100,
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
    Positioned.fill(
      child: Center(
        child: Text(
          widget.category.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ],
),

         
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10),
              child: CustomSearchBar(
                controller: _searchController,
                onSearch: _onSearch,
                onFilterTap: _onFilterTap,
              ),
            ),

            // Display search results
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Displaying results for: $_searchQuery',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

            // Products Content
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state is CategoriesLoading) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  }

                  if (state is ProductsLoaded) {
                    // Filter products for the current category
                    final categoryProducts = state.products
                        .where((product) =>
                            product.category.isEmpty == widget.category.id)
                        .toList();

                    if (categoryProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No products found for ${widget.category.name} category',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: categoryProducts.length,
                      itemBuilder: (context, index) {
                        final product = categoryProducts[index];
                        return ProductCard(product: product);
                      },
                    );
                  }

                  if (state is ProductsError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.red),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
