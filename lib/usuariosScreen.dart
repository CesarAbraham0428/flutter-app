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
  String _selectedRole = 'usuario';
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
  List<Map<String, dynamic>> userList = [];

  // Itera cada usuario y crea un clon del Map para poder modificarlo
  for (var user in users) {
    int userId = user['id'];

    // Clona el mapa para hacerlo mutable
    Map<String, dynamic> userClone = Map<String, dynamic>.from(user);

    // Obtiene el rol del usuario
    List<String> roles = await SQLHelper().getPermissionsForUser(userId);
    userClone['rol'] = roles.isNotEmpty ? roles[0] : 'usuario';

    userList.add(userClone);
  }

  setState(() {
    _users = userList;
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

        // Actualiza el rol en la tabla `rol_permiso`
        await SQLHelper.updateUserRole(_editingUserId!, _selectedRole);
      } else {
        // Crea un nuevo usuario
        int userId = await SQLHelper.createUser(
          _nameController.text,
          _passController.text,
        );

        // Asigna el rol seleccionado
        await SQLHelper().assignRole(userId, _selectedRole);
      }

      _clearForm();
      _fetchUsers();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _passController.clear();
    setState(() {
      _selectedRole = 'usuario';
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
      _selectedRole = user['rol'];
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
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: const [
                      DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
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
                    subtitle: Text('Contraseña: ${user['pass']} | Rol: ${user['rol']}'),
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
