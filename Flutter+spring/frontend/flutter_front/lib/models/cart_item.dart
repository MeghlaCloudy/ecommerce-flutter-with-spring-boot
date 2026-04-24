import 'package:shajgoj/models/product_model.dart';

class CartItem {
  final int id; // cart item ID (itemId) — final রাখো, পরে change হবে না
  final Product product; // product — final রাখো, পরে change হবে না
  int quantity; // ← final সরিয়ে দাও, যাতে update করা যায় (+/-)

  CartItem({required this.id, required this.product, required this.quantity});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['itemId'] as int? ?? 0,
      product: Product(
        id: json['productId'] as int? ?? 0,
        name: json['productName'] as String? ?? 'Unknown Product',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        stockQuantity: json['stockQuantity'] as int? ?? 0,
        active: json['active'] as bool? ?? true,
        description: json['description'] as String?,
        discountPrice: json['discountPrice'] != null
            ? (json['discountPrice'] as num).toDouble()
            : null,
        sku: json['sku'] as String?,
        brandName: json['brandName'] as String?,
        categories: json['categories'] != null
            ? List<String>.from(json['categories'])
            : null,
        images: json['imageUrl'] != null ? [json['imageUrl'] as String] : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
      ),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  // Optional: backend-এ পাঠানোর জন্য
  Map<String, dynamic> toJson() {
    return {'itemId': id, 'productId': product.id, 'quantity': quantity};
  }
}
