import 'package:get/get.dart';
import '../controller/product_controller.dart';
import '../views/pages/product_detail_page.dart';
import '../views/pages/product_page.dart';
import 'app_routes.dart';

// Binding untuk ProductPage
class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
  }
}

// Daftar semua halaman/route dalam aplikasi
class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.products,
      page: () => ProductPage(),
      binding: ProductBinding(),
    ),
    GetPage(name: AppRoutes.detail, page: () => ProductDetailPage()),
  ];
}