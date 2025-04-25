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

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late ProductSearchBloc _productSearchBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _productSearchBloc = ProductSearchBloc(
      productRepository:
          ProductRepository(), // You'll need to import and provide this repository
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _productSearchBloc.close();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
    // Add event to search bloc if needed
    // _productSearchBloc.add(SearchOrdersEvent(query));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: BlocProvider(
        create: (_) => OrdersBloc()..add(StartOrdersStream()),
        child: BlocBuilder<OrdersBloc, OrdersState>(
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
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.boxOpen,
            size: 50,
            color: AppColors.brandAccent,
          ),
          SizedBox(height: 20),
          Text(
            'No orders yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<CompletedOrder> orders) {
    // Filter orders based on search query
    final filteredOrders = _searchQuery.isEmpty
        ? orders
        : orders.where((order) {
            // Search by order ID
            if (order.id.toLowerCase().contains(_searchQuery)) {
              return true;
            }

            // Search by items in the order
            final hasMatchingItem = order.merchantOrders
                .any((item) => item.items.contains(_searchQuery));

            return hasMatchingItem;
          }).toList();

    return Column(
      children: [
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
              ? const Center(
                  child: Text(
                    'No matching orders found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
}
