import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/card-shimmer.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/custom_fab_widget.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_card.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductsBloc>().add(FetchProducts());
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 200.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primaryColor,
                  child: Center(
                    child: Image.asset(
                      'assets/111.png',
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 240,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              sliver: _buildProductsSection(theme),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFAB(),
    );
  }

  Widget _buildProductsSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Products',
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
                            const SizedBox(height: 50),
                            Text(
                              'You have no products yet...',
                              style: GoogleFonts.montaga(
                                textStyle:
                                    theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
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
      ),
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
