// lib/pages/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';
import 'package:flutter_application_2/mail_helper.dart';
import 'package:flutter_application_2/services/inactividad.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _cart = [];
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _loadUserEmail();
    Inactividad().initialize(context);
  }

  @override
  void dispose() {
    Inactividad().dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    final products = await SQLHelper.getAllProductos();
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserEmail() async {
    final email = await SQLHelper.getUserEmail(widget.userId);
    setState(() {
      userEmail = email;
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _quantityController = TextEditingController();
        return AlertDialog(
          title: Text('Agregar ${product['nombre_product']} al carrito'),
          content: TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Cantidad a agregar'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                int cantidad = int.tryParse(_quantityController.text) ?? 0;
                if (cantidad > 0 && cantidad <= product['cantidad_producto']) {
                  await SQLHelper.addToCart(
                    product['id'],
                    product['nombre_product'],
                    product['precio'],
                    cantidad,
                    product['imagen'],
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto agregado al carrito.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cantidad no válida')),
                  );
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewCart() async {
    final cartItems = await SQLHelper.getCartItems();
    if (mounted) {
      setState(() {
        _cart = cartItems;
      });
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Carrito de compras'),
          content: SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final item = _cart[index];
                return ListTile(
                  title: Text(item['nombre_product']),
                  subtitle: Text('Cantidad: ${item['cantidad']} - Precio: \$${item['precio']}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: _confirmPurchase,
              child: const Text('Confirmar compra'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmPurchase() async {
    double total = 0;
    for (var item in _cart) {
      total += item['cantidad'] * item['precio'];
    }
    await MailHelper.send(
      'Resumen de compra',
      '',  // No es necesario enviar imagen
      _cart.length,
      total,
      userEmail ?? '',
    );
    await SQLHelper.clearCart();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra confirmada y correo enviado.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(185, 170, 245, 1),
      appBar: AppBar(
        title: const Text("Catálogo de Productos"),
        backgroundColor: const Color.fromARGB(255, 231, 221, 188),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _viewCart,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No hay productos disponibles'))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: Image.network(
                        product['imagen'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                      title: Text(product['nombre_product']),
                      subtitle: Text(
                        'Precio: \$${product['precio']}  |  Cantidad: ${product['cantidad_producto']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          _addToCart(product);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
