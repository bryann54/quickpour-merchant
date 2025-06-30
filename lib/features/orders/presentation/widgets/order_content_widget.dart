import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/search_bar.dart';
import 'package:quickpourmerchant/features/orders/data/models/completed_order_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/order_item_card.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/order_shimmer.dart';
import 'package:quickpourmerchant/features/product/data/repositories/product_repository.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/search/filter_bottomSheet.dart';
import 'package:quickpourmerchant/features/product_search/presentation/bloc/product_search_bloc.dart';

enum OrderStatus { all, pending, completed }

class OrdersContentWidget extends StatefulWidget {
  final OrderStatus statusFilter;
  final bool showSearchBar;

  const OrdersContentWidget({
    super.key,
    this.statusFilter = OrderStatus.all,
    this.showSearchBar = true,
  });

  @override
  State<OrdersContentWidget> createState() => _OrdersContentWidgetState();
}

class _OrdersContentWidgetState extends State<OrdersContentWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late ProductSearchBloc _productSearchBloc;

  @override
  void initState() {
    super.initState();
    _productSearchBloc = ProductSearchBloc(
      productRepository: ProductRepository(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _productSearchBloc.close();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
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
            _productSearchBloc.add(
              FilterProductsEvent(
                category: filters['category'] as String?,
                store: filters['store'] as String?,
                priceRange: filters['priceRange'] as RangeValues?,
              ),
            );
          },
        ),
      ),
    );
  }

  List<CompletedOrder> _filterOrdersByStatus(List<CompletedOrder> orders) {
    switch (widget.statusFilter) {
      case OrderStatus.pending:
        return orders.where((order) => order.status == 'pending').toList();
      case OrderStatus.completed:
        return orders.where((order) => order.status == 'completed').toList();
      case OrderStatus.all:
        return orders;
    }
  }

  List<CompletedOrder> _filterOrdersBySearch(List<CompletedOrder> orders) {
    if (_searchQuery.isEmpty) return orders;

    return orders.where((order) {
      // Search by username ID
      if (order.userName.toLowerCase().contains(_searchQuery)) {
        return true;
      }

      // Search by items in the order
      final hasMatchingItem =
          order.merchantOrders.any((item) => item.items.contains(_searchQuery));

      return hasMatchingItem;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state is OrdersInitial) {
          return ListView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              return const OrderItemShimmer();
            },
          );
        } else if (state is OrdersEmpty) {
          return _buildEmptyOrdersView();
        } else if (state is OrdersLoaded) {
          return _buildOrdersList(state.orders);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyOrdersView() {
    String emptyMessage;
    switch (widget.statusFilter) {
      case OrderStatus.pending:
        emptyMessage = 'No pending orders';
        break;
      case OrderStatus.completed:
        emptyMessage = 'No completed orders';
        break;
      case OrderStatus.all:
        emptyMessage = 'No orders yet';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.boxOpen,
            size: 50,
            color: AppColors.brandAccent,
          ),
          const SizedBox(height: 20),
          Text(
            emptyMessage,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<CompletedOrder> orders) {
    // Filter orders by status first
    var filteredOrders = _filterOrdersByStatus(orders);

    // Then filter by search query
    filteredOrders = _filterOrdersBySearch(filteredOrders);

    return Column(
      children: [
        if (widget.showSearchBar)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearchBar(
              controller: _searchController,
              onSearch: _onSearch,
              onFilterTap: _onFilterTap,
            ),
          ),
        Expanded(
          child: filteredOrders.isEmpty
              ? Center(
                  child: Text(
                    widget.showSearchBar && _searchQuery.isNotEmpty
                        ? 'No matching orders found'
                        : _getEmptyStateMessage(),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return OrderItemWidget(order: order);
                  },
                ),
        ),
      ],
    );
  }

  String _getEmptyStateMessage() {
    switch (widget.statusFilter) {
      case OrderStatus.pending:
        return 'No pending orders found';
      case OrderStatus.completed:
        return 'No completed orders found';
      case OrderStatus.all:
        return 'No orders found';
    }
  }
}
