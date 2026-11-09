import 'dart:convert';
import '../model/product.dart';
import 'package:http/http.dart' as http;

class ProductService {
  final Uri _url = Uri.parse("https://dummyjson.com/products");

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(_url);
    final result = jsonDecode(response.body);

    final List<dynamic> products = result['products'];

    return products.map((product) => Product.fromJson(product)).toList();
  }
}