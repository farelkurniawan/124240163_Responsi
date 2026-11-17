import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var currentUser = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
    currentUser.value = prefs.getString('loggedInUser') ?? '';
  }

  Future<bool> register(String username, String password) async {
    final box = Hive.box('users');
    if (box.containsKey(username)) {
      return false; 
    }
    await box.put(username, password);
    return true;
  }

  Future<bool> login(String username, String password) async {
    final box = Hive.box('users');
    final savedPassword = box.get(username);

    if (savedPassword != null && savedPassword == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loggedInUser', username);

      isLoggedIn.value = true;
      currentUser.value = username;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('loggedInUser');

    isLoggedIn.value = false;
    currentUser.value = '';
    Get.offAllNamed('/login');
  }
}

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var categories = <String>['All'].obs;
  var selectedCategory = 'All'.obs;
  var isLoading = false.obs;

  var wishlistItems = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
    fetchCategories();
    fetchProducts();
  }

  void loadWishlist() {
    final box = Hive.box('wishlist');
    final List<Product> loaded = [];
    for (var key in box.keys) {
      final item = box.get(key);
      if (item != null && item is Map) {
        loaded.add(Product.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    wishlistItems.assignAll(loaded);
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final response =
          await http.get(Uri.parse('https://dummyjson.com/products'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['products'] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        products.assignAll(list);
      } else {
        products.clear();
        Get.snackbar(
          'Error',
          'Gagal mengambil produk (${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      products.clear();
      Get.snackbar(
        'Error',
        'Gagal memuat produk. Periksa koneksi internet Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('https://dummyjson.com/products/category-list'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final list = data.map((e) => e.toString()).toList();
        categories.assignAll(['All', ...list]);
      }
    } catch (_) {
      if (categories.isEmpty) {
        categories.assignAll(['All']);
      }
    }
  }

  Future<void> filterByCategory(String category) async {
    selectedCategory.value = category;
    if (category == 'All' || category.isEmpty) {
      await fetchProducts();
      return;
    }

    isLoading.value = true;
    try {
      final response = await http
          .get(Uri.parse('https://dummyjson.com/products/category/$category'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['products'] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        products.assignAll(list);
      } else {
        products.clear();
      }
    } catch (e) {
      products.clear();
      Get.snackbar(
        'Error',
        'Gagal memuat produk kategori $category',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<Product?> fetchProductDetail(int id) async {
    try {
      final response =
          await http.get(Uri.parse('https://dummyjson.com/products/$id'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat detail produk',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return null;
  }

  void toggleWishlist(Product product) {
    final box = Hive.box('wishlist');

    if (box.containsKey(product.id)) {
      box.delete(product.id);
      wishlistItems.removeWhere((item) => item.id == product.id);

      Get.snackbar(
        'Wishlist',
        '${product.title} dihapus dari wishlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.favorite_border, color: Colors.white),
      );
    } else {
      box.put(product.id, product.toJson());
      wishlistItems.add(product);

      Get.snackbar(
        'Wishlist',
        '${product.title} berhasil ditambahkan ke wishlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.favorite, color: Colors.white),
      );
    }
  }

  bool isWishlisted(int id) {
    return wishlistItems.any((item) => item.id == id);
  }
}
