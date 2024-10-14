import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<Map<String, dynamic>> _allUser = [];
  bool _isLoading = true;

  void _refreshUser() async {
    final user = await SQLHelper.getAllUser();
    setState(() {
      _allUser = user;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  final TextEditingController _nombreEditingController = TextEditingController();
  final TextEditingController _descEditingController = TextEditingController();

  Future<void> _addUser() async {
    await SQLHelper.createUser(
      _nombreEditingController.text,
      _descEditingController.text,
    );
    _refreshUser();
  }

  Future<void> _updateUser(int id) async {
    await SQLHelper.updateUser(
      id,
      _nombreEditingController.text,
      _descEditingController.text,
    );
    _refreshUser();
  }

  Future<void> _deleteUser(int id) async {
    await SQLHelper.deleteUser(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      content: Text("Registro eliminado"),
    ));
    _refreshUser();
  }

  void muestraDatos(int? id) {
    if (id != null) {
      final existingUser = _allUser.firstWhere((element) => element['id'] == id);
      _nombreEditingController.text = existingUser['user_name']; 
      _descEditingController.text = existingUser['pass'];
    } else {
      _nombreEditingController.clear();
      _descEditingController.clear();
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nombreEditingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Nombre",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descEditingController,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Descripción",
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addUser();
                  } else {
                    await _updateUser(id);
                  }
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Agregar Usuario" : "Actualizar",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(185, 170, 245, 1),
      appBar: AppBar(
        title: const Text("Ejemplo de SQLite (CRUD USUARIOS)"),
        backgroundColor: const Color.fromARGB(255, 231, 221, 188),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allUser.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _allUser[index]['user_name'],
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  subtitle: Text("Descripcion: ${_allUser[index]['pass']}\nID: ${_allUser[index]['id']} "),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          muestraDatos(_allUser[index]['id']);
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Color.fromARGB(255, 64, 80, 226),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteUser(_allUser[index]['id']);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => muestraDatos(null),
        child: const Icon(Icons.add),
     ),
);
}
}