import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';
import 'package:flutter_application_2/cruds/productos_screen.dart';
import 'package:flutter_application_2/cruds/usuarios_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administrador"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsuariosScreen()),
                );
              },
              child: const Center(
                child: Text('Gestionar Usuarios'),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductosScreen()),
                );
              },
               child: const Center(
                child: Text('Gestionar Productos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}