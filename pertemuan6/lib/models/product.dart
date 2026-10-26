class Product {
  final int id;
  final String title;
  final String description;
  final String thumbnail;
  final String category;
  final double price;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.category,
    required this.price,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images']),
    );
  }
}
