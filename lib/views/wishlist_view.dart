import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/controllers.dart';
import 'detail_view.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: Obx(() {
        if (controller.wishlistItems.isEmpty) {
          return const Center(child: Text('Wishlist masih kosong'));
        }

        return ListView.builder(
          itemCount: controller.wishlistItems.length,
          itemBuilder: (context, index) {
            final product = controller.wishlistItems[index];

            return Dismissible(
              key: Key(product.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                controller.toggleWishlist(product);
              },
              child: ListTile(
                leading: Image.network(
                  product.thumbnail,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                ),
                title: Text(product.title),
                subtitle: Text('\$${product.price}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.toggleWishlist(product),
                ),
                onTap: () => Get.to(() => DetailView(productId: product.id)),
              ),
            );
          },
        );
      }),
    );
  }
}
