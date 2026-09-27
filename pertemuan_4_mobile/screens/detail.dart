import 'package:flutter/material.dart';
import 'package:state/models/product.dart';

class Detail extends StatelessWidget {
  final Product product;

  const Detail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),

      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [Image.network(product.image)]),
        ),
      ),
    );
  }
}
