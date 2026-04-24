class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String? sku;
  final int stockQuantity;
  final bool active;
  final String? brandName;
  final List<String>? categories;
  final List<String>? images;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    this.sku,
    required this.stockQuantity,
    required this.active,
    this.brandName,
    this.categories,
    this.images,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      sku: json['sku'] as String?,
      stockQuantity: json['stockQuantity'] as int,
      active: json['active'] as bool,
      brandName: json['brandName'] as String?,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
