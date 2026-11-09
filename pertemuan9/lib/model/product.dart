class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final int stock;
  final String brand;
  final List<dynamic> tags;
  final List<dynamic> images;
  final List<dynamic> reviews;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.tags,
    required this.images,
    required this.reviews,
  });
  factory Product.fromJson(Map<String, dynamic> jsonData) {
    return Product(
      id: jsonData['id'],
      title: jsonData['title'] ?? '',
      description: jsonData['description'] ?? '',
      price: jsonData['price'] ?? '',
      rating: jsonData['rating'] ?? '',
      stock: jsonData['stock'] ?? '',
      brand: jsonData['brand'] ?? '',
      tags: jsonData['tags'] ?? [],
      images: jsonData['images'] ?? [],
      reviews: jsonData['reviews'] ?? [],
    );
  }
}