//lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  bool _isLoading = true;

  void _refreshUser() async {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(185, 170, 245, 1),
      appBar: AppBar(
        title: const Text("Catalogo de Productos de Ropa"),
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
            children: [
           Container(
            padding: const EdgeInsets.all(20.0),
            child: Image.network(SQLHelper.urlProducto),
          ),
           Container(
            padding: const EdgeInsets.all(20.0),
            child: Image.network(SQLHelper.urlProducto),
          ),
           Container(
            padding: const EdgeInsets.all(20.0),
            child: Image.network(SQLHelper.urlProducto),
          ),
           Container(
            padding: const EdgeInsets.all(20.0),
            child: Image.network(SQLHelper.urlProducto),
          ),
           Container(
            padding: const EdgeInsets.all(20.0),
            child: Image.network(SQLHelper.urlProducto),
          ),
           Container(
            padding: const EdgeInsets.all(20.0),
            child: Image.network(SQLHelper.urlProducto),
          )
            ]
          )
    );
  }
}