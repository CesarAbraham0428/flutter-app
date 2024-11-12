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
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _loadUserEmail();
    Inactividad()
        .initialize(context); // Inicia el temporizador al abrir HomeScreen
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

void _buyProduct(Map<String, dynamic> product) {
  Inactividad().startTimer(context);
  showDialog(
    context: context,
    builder: (context) {
      final TextEditingController _quantityController = TextEditingController();
      final TextEditingController _emailController = TextEditingController();
      
      // Pre-fill email if available
      if (userEmail != null) {
        _emailController.text = userEmail!;
      }

      return AlertDialog(
        title: Text('Comprar ${product['nombre_product']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cantidad disponible: ${product['cantidad_producto']}'),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Cantidad a comprar'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              enabled: false, // Make it read-only since we're using user's email
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              int cantidadComprada = int.tryParse(_quantityController.text) ?? 0;
              
              if (cantidadComprada > 0 &&
                  cantidadComprada <= product['cantidad_producto'] &&
                  userEmail != null) {
                double precioTotal = cantidadComprada.toDouble() * product['precio'];
                int nuevaCantidad = product['cantidad_producto'] - cantidadComprada;

                await SQLHelper.updateProducto(
                  product['id'],
                  product['nombre_product'],
                  product['precio'],
                  nuevaCantidad,
                  product['imagen'],
                );

                await MailHelper.send(
                  product['nombre_product'],
                  product['imagen'],
                  cantidadComprada,
                  precioTotal,
                  userEmail!, // Use the stored user email
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compra realizada con éxito. Se ha enviado un correo.'),
                    ),
                  );
                  Navigator.pop(context);
                }

                _fetchProducts();
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cantidad no válida o correo no disponible')),
                  );
                }
              }
            },
            child: const Text('Comprar'),
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
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
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
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                          _buyProduct(product);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
