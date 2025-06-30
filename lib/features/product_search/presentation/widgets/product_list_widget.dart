import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/card-shimmer.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_card.dart';

class ProductListWidget extends StatelessWidget {
  const ProductListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (_isInitialLoading(state)) {
          return _buildShimmerGrid();
        }

        if (state is ProductsError) {
          return _buildErrorView(context, state);
        }

        if (state is ProductsLoaded) {
          return _buildProductGrid(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  bool _isInitialLoading(ProductsState state) {
    return state is ProductsLoading && state is! ProductsLoaded;
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ProductCardShimmer(),
    );
  }

  Widget _buildErrorView(BuildContext context, ProductsError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60),
          const SizedBox(height: 16),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ProductsBloc>().add(FetchProducts());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, ProductsLoaded state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (_shouldLoadMore(scrollInfo, state)) {
          context.read<ProductsBloc>().add(LoadMoreProductsEvent());
          return true;
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _calculateItemCount(state),
        itemBuilder: (context, index) => _buildGridItem(state, index),
      ),
    );
  }

  bool _shouldLoadMore(ScrollNotification scrollInfo, ProductsLoaded state) {
    return scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent * 0.9 &&
        state.hasMoreData &&
        state is! LoadMoreProductsEvent;
  }

  int _calculateItemCount(ProductsLoaded state) {
    return state.products.length + (state.hasMoreData ? 2 : 0);
  }

  Widget _buildGridItem(ProductsLoaded state, int index) {
    if (index >= state.products.length) {
      return const ProductCardShimmer();
    } else {
      final product = state.products[index];
      return ProductCard(product: product);
    }
  }
}
