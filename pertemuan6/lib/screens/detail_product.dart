import 'package:flutter/material.dart';
import 'package:pertemuan6/models/product.dart';
import 'package:pertemuan6/services/api_service.dart';

class DetailProduct extends StatefulWidget {
  final int id;
  const DetailProduct({super.key, required this.id});

  @override
  State<DetailProduct> createState() => _DetailProductState();
}

class _DetailProductState extends State<DetailProduct> {
  Product? _product;
  bool _isLoading = true;

  Future<void> _fetchSingleProduct() async {
    final productData = await ApiService.getSingleProduct(widget.id);

    setState(() {
      _product = productData;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchSingleProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_product?.title ?? '')),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
        children: [
          Image.network(_product?.thumbnail ?? ''),
          Text(_product?.title ?? ''),
          Text(_product?.description ?? ''),
          // Text(_product?.price.toString()),
        ],
      )
    );
  }
}