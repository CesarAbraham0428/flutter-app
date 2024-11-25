//lib\pages\product_list_page.dart
import 'package:flutter/material.dart';
import '../services/product_service.dart';

class ProductListPage extends StatefulWidget {
  final ProductService productService;

  const ProductListPage({required this.productService});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> _allProducts = []; // Todos los productos recibidos del servidor
  List<Product> _filteredProducts = []; // Productos filtrados para mostrar
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);

    try {
      // Obtenemos todos los productos del servidor
      final products = await widget.productService.fetchProducts();

      setState(() {
        _allProducts = products;
        _applyLocalFilters(); // Aplicar filtros locales
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyLocalFilters() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final searchText = _searchController.text.trim().toLowerCase();
        final categoryText = _categoryController.text.trim().toLowerCase();
        final minPrice = double.tryParse(_minPriceController.text.trim()) ?? 0;
        final maxPrice =
            double.tryParse(_maxPriceController.text.trim()) ?? double.infinity;

        final matchesSearch = searchText.isEmpty ||
            product.title.toLowerCase().contains(searchText);
        final matchesCategory = categoryText.isEmpty ||
            product.category.toLowerCase() == categoryText;
        final matchesPrice =
            product.price >= minPrice && product.price <= maxPrice;

        return matchesSearch && matchesCategory && matchesPrice;
      }).toList();
    });
  }

  void _applyFilters() {
    _applyLocalFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar productos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                hintText: 'Filtrar por categoría (e.g., electronics)',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    decoration: const InputDecoration(
                      hintText: 'Precio mínimo',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    decoration: const InputDecoration(
                      hintText: 'Precio máximo',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Aplicar Filtros'),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? const Center(child: Text('No se encontraron productos.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Dos productos por fila
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            elevation: 4.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1.5,
                                  child: Image.network(
                                    product.image,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                size: 50),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    product.category,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
