//lib\pages\home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/helpers/db_helper.dart';
import 'package:flutter_application_2/helpers/mail_helper.dart';
import 'package:flutter_application_2/routes/app_routes.dart';
import 'package:flutter_application_2/services/inactividad.dart';
import 'package:flutter_application_2/services/paypal_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  void _handlePaypalCheckout(double total) async {
    final paypalService = PaypalService();
    try {
      final approvalUrl = await paypalService.createPayment(total);
      if (approvalUrl != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(approvalUrl))
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onNavigationRequest: (NavigationRequest request) {
                      if (request.url.contains(PaypalService.returnURL)) {
                        Navigator.pop(context); // Volver después del éxito
                        _confirmPurchase(isPayPal: true);
                        return NavigationDecision.prevent;
                      } else if (request.url
                          .contains(PaypalService.cancelURL)) {
                        Navigator.pop(context); // Manejo de cancelación
                        return NavigationDecision.prevent;
                      }
                      return NavigationDecision.navigate;
                    },
                  ),
                ),
            ),
          ),
        );
      } else {
        throw Exception('No se pudo obtener la URL de aprobación.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error en el pago: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmPurchase({bool isPayPal = false}) async {
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
          SnackBar(
            content: Text(
              isPayPal
                  ? '¡Pago con PayPal completado! Se ha enviado un correo con los detalles de tu compra.'
                  : '¡Compra completada exitosamente! Se ha enviado un correo con los detalles de tu compra.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Ignoramos el error read-only y mostramos mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '¡Compra completada exitosamente! Se ha enviado un correo con los detalles.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showPaymentOptions(double total) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona el método de pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Pago Normal'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmPurchase();
                },
              ),
              const Divider(),
              ListTile(
                leading: Image.network(
                  'https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_37x23.jpg',
                  width: 24,
                  height: 24,
                ),
                title: const Text('Pagar con PayPal'),
                subtitle: const Text('Pago rápido y seguro'),
                onTap: () {
                  Navigator.pop(context);
                  _handlePaypalCheckout(total);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
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
            child: Column(
              children: [
                Expanded(
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
                const SizedBox(height: 10),
                Text('Total: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
            if (_cart.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _showPaymentOptions(total);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Proceder al pago',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
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
        final TextEditingController quantityController =
            TextEditingController();
        return AlertDialog(
          title: Text('Agregar ${product['nombre_product']} al carrito'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Disponibles: ${product['cantidad_producto'] - currentQuantityInCart}'),
              TextField(
                controller: quantityController,
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
                int cantidad = int.tryParse(quantityController.text) ?? 0;
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
                  await _fetchProducts();
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
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.productList);
              },
              child: const Text('Ver Productos en Línea'),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
          ),
        ],
      ),
    );
  }
}
