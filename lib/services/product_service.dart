//lib/services/product_service.dart
import 'package:flutter_application_2/helpers/http.dart';
import 'package:flutter_application_2/helpers/http_method.dart';

class ProductService {
  final Http http;

  ProductService({required this.http});

  Future<List<Product>> fetchProducts(
      {String? search,
      String? category,
      double? minPrice,
      double? maxPrice}) async {
    final queryParameters = {
      if (category != null) 'category': category, // Solo se incluye `category`.
    };

    // Obtenemos todos los productos
    final products = await http.request<List<Product>>(
      '/products',
      method: HttpMethod.get,
      queryParameters: queryParameters,
      parser: (data) => (data as List).map((e) => Product.fromJson(e)).toList(),
    );

    // Aplicamos los filtros adicionales en el cliente
    return products.where((product) {
      final matchesSearch = search == null ||
          product.title.toLowerCase().contains(search.toLowerCase());
      final matchesPrice = (minPrice == null || product.price >= minPrice) &&
          (maxPrice == null || product.price <= maxPrice);
      return matchesSearch && matchesPrice;
    }).toList();
  }
}

class Product {
  final int id;
  final String title;
  final String category;
  final double price;
  final String image;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
    );
  }
}
