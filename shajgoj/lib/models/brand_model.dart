class Brand {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;

  Brand({required this.id, required this.name, this.description, this.logoUrl});

  // JSON থেকে Brand বানানো
  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );
  }

  // Brand থেকে JSON বানানো (create/update-এর জন্য)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      // logoUrl backend থেকে আসে, তাই create-এ পাঠানো লাগে না
    };
  }
}
