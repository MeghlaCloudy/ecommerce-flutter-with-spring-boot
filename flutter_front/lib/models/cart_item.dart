class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final double? discountPrice;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    this.discountPrice,
    this.imageUrl,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
    );
  }
}
