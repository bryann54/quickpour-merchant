class Order {
  final String id;
  final DateTime date;
  final double total;
  final String address;
  final String phoneNumber;
  final String paymentMethod;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.date,
    required this.total,
    required this.address,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.items,
  });
}

class OrderItem {
  final String productName;
  final double price;
  final int quantity;

  OrderItem({
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
}

