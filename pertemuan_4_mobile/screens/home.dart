import 'package:flutter/material.dart';
import 'package:state/screens/detail.dart';
import '../models/product.dart';

// Widget Class
class Home extends StatefulWidget {
  final String username;

  const Home({super.key, required this.username});

  @override
  State<Home> createState() => _HomeState();
}

// State Class
class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return ListTile(
          leading: Image.network(product.image),
          title: Text(product.name),
          subtitle: Text("Rp.${product.price}"),
          trailing: Icon(Icons.arrow_right_sharp),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Detail(product: product)),
            );
          },
        );
      },
    );
  }
}
