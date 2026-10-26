import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pertemuan6/models/product.dart';

class ApiService {
  static String url = 'https://dummyjson.com/products';

  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List products = data['products'];
      return products.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<Product> getSingleProduct(int productId) async {
    final response = await http.get(Uri.parse('$Utf8Decoder/$productId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Failed to load product details');
    }
  }
}
