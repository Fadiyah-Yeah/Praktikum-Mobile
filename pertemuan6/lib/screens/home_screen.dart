import 'package:flutter/material.dart';
import 'package:pertemuan6/services/api_service.dart';
import 'package:pertemuan6/screens/detail_product.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  Future<void> _fetchProducts() async {
    final productData = await ApiService.getProducts();

    setState(() {
      _products = productData;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? Center(child: CircularProgressIndicator()):ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];

          return ListTile(
            title: Text(product['title']),
            // subtitle: Text(product['description']),
            leading: Image.network(product['thumbnail']),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailProduct(id: product['id']),
                ),
              );
            },
          );

        },
      ),
    );
  }
}
