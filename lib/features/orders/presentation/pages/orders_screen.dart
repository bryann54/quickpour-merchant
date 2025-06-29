import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/order_content_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: BlocProvider(
        create: (_) => OrdersBloc()..add(StartOrdersStream()),
        child: TabBarView(
          controller: _tabController,
          children: const [
            OrdersContentWidget(
              statusFilter: OrderStatus.all,
              showSearchBar: true,
            ),
            OrdersContentWidget(
              statusFilter: OrderStatus.pending,
              showSearchBar: true,
            ),
            OrdersContentWidget(
              statusFilter: OrderStatus.completed,
              showSearchBar: true,
            ),
          ],
        ),
      ),
    );
  }
}
