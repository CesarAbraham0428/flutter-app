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
    final products = await http.request<List<Product>>(
      'https://api.escuelajs.co/api/v1/products',
      method: HttpMethod.get,
      parser: (data) {
        if (data is List) {
          return data.map((e) => Product.fromJson(e)).toList();
        } else {
          throw Exception("La API devolvió un formato no soportado");
        }
      },
    );

    // Filtrar productos incompletos o inválidos
    final filteredProducts = products.where((product) {
      final hasValidName =
          product.title != "New Product" && product.title != "product 00";
      final hasValidCategoryPrice =
          !(product.category == "Clothes" && product.price == 10);
      final hasValidImage = product.image.isNotEmpty;
      final hasValidElectronicsImage =
          !(product.category == "electronics" && product.image.isEmpty);

      return hasValidName &&
          hasValidCategoryPrice &&
          hasValidImage &&
          hasValidElectronicsImage;
    }).toList();

    // Aplicamos los filtros locales (search, category, minPrice, maxPrice)
    return filteredProducts.where((product) {
      final matchesSearch = search == null ||
          product.title.toLowerCase().contains(search.toLowerCase());
      final matchesCategory = category == null ||
          product.category.toLowerCase() == category.toLowerCase();
      final matchesPrice = (minPrice == null || product.price >= minPrice) &&
          (maxPrice == null || product.price <= maxPrice);
      return matchesSearch && matchesCategory && matchesPrice;
    }).toList();
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final String category; // Ahora almacenaremos solo el nombre de la categoría.
  final double price;
  final String image; // Usaremos la primera imagen disponible en la lista.

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Extraer el nombre de la categoría y la primera imagen.
    final categoryName = json['category']['name'] as String;
    final images = json['images'] as List<dynamic>;

    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: categoryName,
      price: (json['price'] as num).toDouble(),
      image: images.isNotEmpty
          ? images.first as String
          : '', // Usa la primera imagen o un valor vacío.
    );
  }
}
