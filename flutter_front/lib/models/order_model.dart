class Order {
  final int id;
  final String orderNumber;
  final DateTime orderDate;
  final double totalAmount;
  final String
  status; // 'PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'
  final String paymentMethod;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String postalCode;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.postalCode,
    required this.address,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'],
      orderDate: DateTime.parse(json['orderDate']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      fullName: json['fullName'],
      phone: json['phone'] ?? 'N/A', // ← backend থেকে না এলে 'N/A'
      address: json['address'],
      city: json['city'],
      postalCode: json['postalCode'],
      items: (json['items'] as List<dynamic>)
          .map((i) => OrderItem.fromJson(i))
          .toList(),
    );
  }
}

class OrderItem {
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productName: json['productName'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
    );
  }
}
