class Category {
  final int id;
  final String name;
  final String? imageUrl;
  final int? parentId; // sub-category-এর জন্য

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      parentId: json['parentId'] as int?,
    );
  }
}
