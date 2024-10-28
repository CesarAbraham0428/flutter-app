import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Panel de Administrador"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Navegar a gestión de usuarios
            },
            child: Text('Gestionar Usuarios'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navegar a gestión de productos
            },
            child: Text('Gestionar Productos'),
          ),
        ],
      ),
    );
  }
}
