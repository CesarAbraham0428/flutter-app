import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({Key? key}) : super(key: key);

  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
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

    for (var user in users) {
      int userId = user['id'];
      Map<String, dynamic> userClone = Map<String, dynamic>.from(user);
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
        // Actualiza el usuario con la nueva contraseña encriptada
        if (_passController.text.isNotEmpty) {
          await SQLHelper.updateUser(
            _editingUserId!,
            _nameController.text,
            _passController.text,
          );
        }

        // Actualiza el rol
        await SQLHelper.updateUserRole(_editingUserId!, _selectedRole);
      } else {
        // Crea un nuevo usuario con la contraseña encriptada
        int userId = await SQLHelper.createUser(
          _nameController.text,
          _passController.text,
        );

        // Asigna el rol
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
      _passController.clear(); // No mostramos la contraseña
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
                    decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
                    obscureText: true,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return null; // La contraseña puede ser vacía si no se quiere cambiar
                      }
                      if (value == null || value.isEmpty) {
                        return 'Ingrese una contraseña';
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
                    subtitle: Text('Rol: ${user['rol']}'),
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
