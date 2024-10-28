import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({Key? key}) : super(key: key);

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isEditing = false;
  int? _editingUserId;

  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await SQLHelper.getAllUser();
    setState(() {
      _users = users;
    });
  }

  Future<void> _submitUser() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditing && _editingUserId != null) {
        await SQLHelper.updateUser(
          _editingUserId!,
          _nameController.text,
          _passController.text,
        );
      } else {
        await SQLHelper.createUser(
          _nameController.text,
          _passController.text,
        );
      }

      _clearForm();
      _fetchUsers();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _passController.clear();
    setState(() {
      _isEditing = false;
      _editingUserId = null;
    });
  }

  void _startEditing(Map<String, dynamic> user) {
    setState(() {
      _isEditing = true;
      _editingUserId = user['id'];
      _nameController.text = user['user_name'];
      _passController.text = user['pass'];
    });
  }

  Future<void> _deleteUser(int id) async {
    await SQLHelper.deleteUser(id);
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Usuarios')),
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
                    decoration: const InputDecoration(labelText: 'Nombre del usuario'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el nombre del usuario';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese la contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitUser,
                    child: Text(_isEditing ? 'Actualizar Usuario' : 'Agregar Usuario'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    title: Text(user['user_name']),
                    subtitle: Text('Contraseña: ${user['pass']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _startEditing(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user['id']),
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
