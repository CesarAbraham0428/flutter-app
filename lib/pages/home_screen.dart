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
      });
    }
  }

  Future<void> _loadUserEmail() async {
    final email = await SQLHelper.getUserEmail(widget.userId);
    setState(() {
      userEmail = email;
    });
  }

  Future<void> _viewCart() async {
    final cartItems = await SQLHelper.getCartItems();
    if (mounted) {
      setState(() {
        _cart = cartItems;
      });
    }
    double total =
        _cart.fold(0, (sum, item) => sum + item['cantidad'] * item['precio']);

    if (!mounted) return;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
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
                  subtitle: Text(
                      'Cantidad: ${item['cantidad']} - Precio: \$${item['precio']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await SQLHelper.removeFromCart(item['productId']);
                      Navigator.pop(dialogContext);
                      if (mounted) {
                        _viewCart();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: _cart.isEmpty
                  ? null
                  : () async {
                      await _confirmPurchase();
                      Navigator.pop(dialogContext);
                    },
              child: Text(
                  'Confirmar compra (Total: \$${total.toStringAsFixed(2)})'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmPurchase() async {
    try {
      double total = 0;
      for (var item in _cart) {
        total += item['cantidad'] * item['precio'];
        await SQLHelper.updateProductStock(item['productId'], item['cantidad']);
      }

      await MailHelper.send(
        _cart,
        total,
        userEmail ?? '',
      );

      await SQLHelper.clearCart();

      if (mounted) {
        setState(() {
          _cart.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '¡Compra completada exitosamente! Se ha enviado un correo con los detalles.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '¡Compra completada exitosamente! Se ha enviado un correo con los detalles.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final cartItems = await SQLHelper.getCartItemsForProduct(product['id']);
    int currentQuantityInCart =
        cartItems.fold(0, (sum, item) => sum + (item['cantidad'] as int));

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final TextEditingController _quantityController =
            TextEditingController();
        return AlertDialog(
          title: Text('Agregar ${product['nombre_product']} al carrito'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Disponibles: ${product['cantidad_producto'] - currentQuantityInCart}'),
              TextField(
                controller: _quantityController,
                decoration:
                    const InputDecoration(labelText: 'Cantidad a agregar'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                int cantidad = int.tryParse(_quantityController.text) ?? 0;
                int newTotalInCart = currentQuantityInCart + cantidad;

                if (cantidad > 0 &&
                    newTotalInCart <= product['cantidad_producto']) {
                  await SQLHelper.addToCart(
                    product['id'],
                    product['nombre_product'],
                    product['precio'],
                    cantidad,
                    product['imagen'],
                  );
                  Navigator.pop(dialogContext);
                  await _fetchProducts(); // Refresh products list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Producto agregado al carrito.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Cantidad no válida o supera el stock disponible')),
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Llama a la función de cierre de sesión
          ),
        ],
      ),
      body: ListView.builder(
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
            subtitle: Text('Precio: \$${product['precio']}'),
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
