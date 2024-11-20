//lib/cruds/usuarios_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/helpers/db_helper.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({Key? key}) : super(key: key);

  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  String _selectedRole = 'usuario';
  bool _isEditing = false;
  int? _editingUserId;
  bool _obscurePassword = true; // Controla la visibilidad de la contraseña
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

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

  void _validatePassword(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'\d'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
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
            _emailController.text,
            _passController.text,
          );
        }

        // Actualiza el rol
        await SQLHelper.updateUserRole(_editingUserId!, _selectedRole);
      } else {
        // Crea un nuevo usuario con la contraseña encriptada
        int userId = await SQLHelper.createUser(
          _nameController.text,
          _emailController.text,
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
    _emailController.clear();
    _passController.clear();
    setState(() {
      _selectedRole = 'usuario';
      _isEditing = false;
      _editingUserId = null;
      _obscurePassword = true;
      _hasMinLength = false;
      _hasUpperCase = false;
      _hasNumber = false;
      _hasSpecialChar = false;
    });
  }

  void _startEditing(Map<String, dynamic> user) async {
    setState(() async {
      _isEditing = true;
      _editingUserId = user['id'];
      _nameController.text = user['user_name'];
      _emailController.text = user['email'];
      _passController.clear(); // No mostramos la contraseña en el formulario
      List<String> roles = await SQLHelper().getPermissionsForUser(user['id']);
      _selectedRole = roles.isNotEmpty ? roles[0] : 'usuario';
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
                    decoration:
                        const InputDecoration(labelText: 'Nombre del usuario'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el nombre del usuario';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration:
                        const InputDecoration(labelText: 'Correo del usuario'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el correo del usuario';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Ingrese un correo válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passController,
                    obscureText: _obscurePassword, // Usamos _obscurePassword
                    onChanged: _validatePassword, // Validar en tiempo real
                    decoration: InputDecoration(
                      labelText: 'Nueva Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword; // Alternar visibilidad
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return null; // La contraseña puede ser vacía si no se quiere cambiar
                      }
                      if (value == null || value.isEmpty) {
                        return 'Ingrese una contraseña';
                      }
                      if (!_hasMinLength ||
                          !_hasUpperCase ||
                          !_hasNumber ||
                          !_hasSpecialChar) {
                        return 'La contraseña no cumple con los requisitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Pie de página con los requisitos de la contraseña
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Requisitos de la contraseña:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '• Al menos 8 caracteres',
                        style: TextStyle(
                          color: _hasMinLength ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        '• Al menos una letra mayúscula',
                        style: TextStyle(
                          color: _hasUpperCase ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        '• Al menos un número',
                        style: TextStyle(
                          color: _hasNumber ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        '• Al menos un carácter especial (!@#\$%^&*)',
                        style: TextStyle(
                          color: _hasSpecialChar ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: const [
                      DropdownMenuItem(
                          value: 'usuario', child: Text('Usuario')),
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
                    child: Text(
                        _isEditing ? 'Actualizar Usuario' : 'Agregar Usuario'),
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
                    subtitle: Text(
                      'Correo: ${user['email']}\nRol: ${user['rol']}',
                    ),
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
