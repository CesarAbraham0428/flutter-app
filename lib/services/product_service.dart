import 'package:flutter_application_2/helpers/http.dart';
import 'package:flutter_application_2/helpers/http_method.dart';

class ProductService {
  final Http http;

  ProductService({required this.http});

  Future<List<Product>> fetchProducts({String? search, String? category}) async {
    final queryParameters = {
      if (search != null) 'search': search,
      if (category != null) 'category': category,
    };

    return await http.request<List<Product>>(
      '/products',
      method: HttpMethod.get,
      queryParameters: queryParameters,
      parser: (data) => (data as List).map((e) => Product.fromJson(e)).toList(),
    );
  }
}

class Product {
  final int id;
  final String title;
  final String category;
  final double price;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
