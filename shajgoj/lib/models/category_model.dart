class Category {
  final int id;
  final String name;
  final String? imageUrl;
  final int? parentId;

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

  Map<String, dynamic> toJson() {
    return {'name': name, if (parentId != null) 'parentId': parentId};
  }
}
