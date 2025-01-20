import 'package:quickpourmerchant/features/orders/data/models/order_model.dart';

class OrdersRepository {
  final List<Order> _orders = [];

  List<Order> getOrders() {
    return List.unmodifiable(_orders);
  }

  void addOrder(Order order) {
    _orders.add(order);
  }

  void clearOrders() {
    _orders.clear();
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      // Return null if no match is found
      return null;
    }
  }
  Future<int> fetchOrdersCount() async {
    final orders = await getOrders(); // Assuming this method exists
    return orders.length;
  }

  Future<int> fetchFeedbackCount() async {
    final orders = await getOrders();
    // ignore: unnecessary_null_comparison
    return orders.where((order) => order.id != null).length;
  }
}
