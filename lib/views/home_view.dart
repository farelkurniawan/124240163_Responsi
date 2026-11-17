import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/controllers.dart';
import 'detail_view.dart';
import 'wishlist_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final productController = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ShoppingHub', style: TextStyle(fontSize: 18)),
              Text(
                'Halo, ${authController.currentUser.value}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Get.to(() => const WishlistView()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Kategori
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text(
                  'Kategori: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => DropdownButton<String>(
                    value: productController.selectedCategory.value,
                    items: productController.categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        productController.filterByCategory(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List Produk
          Expanded(
            child: Obx(() {
              if (productController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productController.products.isEmpty) {
                return const Center(child: Text('Produk tidak ditemukan'));
              }

              return ListView.builder(
                itemCount: productController.products.length,
                itemBuilder: (context, index) {
                  final product = productController.products[index];
                  return ListTile(
                    leading: Image.network(
                      product.thumbnail,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    ),
                    title: Text(product.title),
                    subtitle: Text('${product.category} - \$${product.price}'),
                    trailing: Obx(() {
                      final isFav = productController.isWishlisted(product.id);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                        onPressed: () =>
                            productController.toggleWishlist(product),
                      );
                    }),
                    onTap: () => Get.to(() => DetailView(productId: product.id)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
