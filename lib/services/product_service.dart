//lib/services/product_service.dart
import 'package:flutter_application_2/helpers/http.dart';
import 'package:flutter_application_2/helpers/http_method.dart';

class ProductService {
  final Http http;

  ProductService({required this.http});

  Future<List<Product>> fetchProducts({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    // Ajuste para garantizar que se envía el filtro correctamente
    final queryParameters = {
      if (category != null && category.isNotEmpty) 'category': category,
    };

    try {
      final products = await http.request<List<Product>>(
        '/products',
        method: HttpMethod.get,
        queryParameters: queryParameters,
        parser: (data) =>
            (data as List).map((e) => Product.fromJson(e)).toList(),
      );

      // Filtros adicionales en el cliente
      return products.where((product) {
        final matchesSearch = search == null ||
            product.title.toLowerCase().contains(search.toLowerCase());
        final matchesPrice = (minPrice == null || product.price >= minPrice) &&
            (maxPrice == null || product.price <= maxPrice);
        return matchesSearch && matchesPrice;
      }).toList();
    } catch (error) {
      throw Exception('Error al obtener productos: $error');
    }
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
