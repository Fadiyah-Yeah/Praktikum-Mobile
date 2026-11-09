import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/product_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class ProductPage extends StatelessWidget {
  ProductPage({super.key});

  // Get.put() → mendaftarkan controller ke GetX
  // Cukup sekali di sini; halaman lain tinggal Get.find()
   final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Home Page')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        // Obx() mendengarkan semua variabel reaktif di dalamnya.
        // Hanya bagian ini yang dirender ulang saat state berubah.
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueGrey),
            );
          }
          return GridView.builder(
            itemCount: controller.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return ProductCard(
                product: controller.products[index],
                onTap: () {
                  Get.toNamed(
                    AppRoutes.detail,
                    arguments: controller.products[index],
                  );
                },

              );
            },
          );
        }),
      ),
    );
  }
}