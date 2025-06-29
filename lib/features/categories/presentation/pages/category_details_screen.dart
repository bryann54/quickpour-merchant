import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/categories/domain/entities/category.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/search_bar.dart';
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
      _searchQuery = query.toLowerCase();
    });
  }

  void _onFilterTap() {
    print('Filter button tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            iconTheme: const IconThemeData(color: AppColors.background),
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroSection(),
              collapseMode: CollapseMode.parallax,
            ),
          ),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: CustomSearchBar(
              controller: _searchController,
              onSearch: _onSearch,
              onFilterTap: _onFilterTap,
            ),
          )),
          if (_searchQuery.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  'Displaying results for: $_searchQuery',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          _buildProductList(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      children: [
        Hero(
          tag: 'category_image${widget.category.id}',
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.accentColor.withValues(alpha: 0.4)),
              image: DecorationImage(
                image: CachedNetworkImageProvider(widget.category.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3),
                  BlendMode.darken,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Hero(
              tag: 'category_name${widget.category.id}',
              child: Text(
                widget.category.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return SliverFillRemaining(
      child: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (state is ProductsLoaded) {
            final categoryProducts = state.products.where((product) {
              final matchesCategory = product.categoryName.toLowerCase() ==
                  widget.category.name.toLowerCase();
              final matchesSearch = _searchQuery.isEmpty ||
                  product.productName.toLowerCase().contains(_searchQuery);
              return matchesCategory && matchesSearch;
            }).toList();

            if (categoryProducts.isEmpty) {
              return Center(
                  child: Text(
                _searchQuery.isEmpty
                    ? 'No products found in ${widget.category.name}'
                    : 'No products match your search',
                style: Theme.of(context).textTheme.bodyMedium,
              ));
            }

            return GridView.builder(
              padding: const EdgeInsets.only(top: 16, left: 3, right: 3),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

          if (state is ProductErrorEvent) {
            return Center(
              child: Text(
                'Error loading products for ${widget.category.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
