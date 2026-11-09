import 'package:get/get.dart';
import '../model/product.dart';
import '../service/product_service.dart';

class ProductController extends GetxController {
  // Dependency
  final ProductService _productService = ProductService();

  // State (variabel reaktif)
  final RxList<Product> _products = <Product>[].obs;
  final RxBool _isLoading = false.obs;

  // Getter (akses dari luar pakai dot notation)
  List<Product> get products => _products;
  bool get isLoading => _isLoading.value;

  // Lifecycle
  @override
  void onInit() {
    _retrieveData();
    super.onInit();
  }

  // Logika (mengambil data dari API untuk ditampilkan di UI)
  Future<void> _retrieveData() async {
    try {
      _isLoading.value = true;

      final data = await _productService.fetchProducts();
      _products.assignAll(data);

      _isLoading.value = false;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}