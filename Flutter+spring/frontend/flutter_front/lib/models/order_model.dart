import 'package:shajgoj/models/cart_item.dart';

class Order {
  final int orderId;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final String paymentMethod;
  final List<CartItem> items; // CartItem reuse করা হলো
  final DateTime createdAt;
  final String userName;
  final String shippingAddressInfo;

  Order({
    required this.orderId,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.paymentMethod,
    required this.items,
    required this.createdAt,
    required this.userName,
    required this.shippingAddressInfo,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] as int,
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: json['userName'] as String? ?? 'Unknown',
      shippingAddressInfo:
          json['shippingAddressInfo'] as String? ?? 'No address',
    );
  }
}
