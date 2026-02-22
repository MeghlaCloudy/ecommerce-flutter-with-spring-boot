class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String? sku;
  final int stockQuantity;
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
    this.brandName,
    this.categories,
    this.images,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      sku: json['sku'],
      stockQuantity: json['stockQuantity'],
      brandName: json['brandName'],
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
