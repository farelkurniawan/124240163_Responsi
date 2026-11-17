class Product {
  final int id;
  final String title;
  final String category;
  final double price;
  final double rating;
  final String description;
  final double discountPercentage;
  final int stock;
  final String thumbnail;
  final String? brand;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.rating,
    required this.description,
    required this.discountPercentage,
    required this.stock,
    required this.thumbnail,
    this.brand,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      thumbnail: json['thumbnail']?.toString() ?? '',
      brand: json['brand'] != null && json['brand'].toString().trim().isNotEmpty
          ? json['brand'].toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'price': price,
      'rating': rating,
      'description': description,
      'discountPercentage': discountPercentage,
      'stock': stock,
      'thumbnail': thumbnail,
      'brand': brand,
    };
  }
}
