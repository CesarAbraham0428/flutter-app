import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({Key? key}) : super(key: key);

  @override
  _ManageProductsScreenState createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  bool _isEditing = false;
  int? _editingProductId;

  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final products = await SQLHelper.getAllProductos();
    setState(() {
      _products = products;
    });
  }

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditing && _editingProductId != null) {
        await SQLHelper.updateProducto(
          _editingProductId!,
          _nameController.text,
          double.parse(_priceController.text),
          int.parse(_quantityController.text),
          _imageUrlController.text,
        );
      } else {
        await SQLHelper.createProducto(
          _nameController.text,
          double.parse(_priceController.text),
          int.parse(_quantityController.text),
          _imageUrlController.text,
        );
      }

      _clearForm();
      _fetchProducts();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _quantityController.clear();
    _imageUrlController.clear();
    setState(() {
      _isEditing = false;
      _editingProductId = null;
    });
  }

  void _startEditing(Map<String, dynamic> product) {
    setState(() {
      _isEditing = true;
      _editingProductId = product['id'];
      _nameController.text = product['nombre_product'];
      _priceController.text = product['precio'].toString();
      _quantityController.text = product['cantidad_producto'].toString();
      _imageUrlController.text = product['imagen'];
    });
  }

  Future<void> _deleteProduct(int id) async {
    await SQLHelper.deleteProducto(id);
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Productos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del producto'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el nombre del producto';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || double.tryParse(value) == null) {
                        return 'Ingrese un precio válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return 'Ingrese una cantidad válida';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'URL de la imagen'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese una URL de imagen';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitProduct,
                    child: Text(_isEditing ? 'Actualizar Producto' : 'Agregar Producto'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ListTile(
                    leading: Image.network(
                      product['imagen'],
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                    ),
                    title: Text(product['nombre_product']),
                    subtitle: Text('Precio: \$${product['precio']}  |  Cantidad: ${product['cantidad_producto']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _startEditing(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(product['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
