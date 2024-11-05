import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  // Función para validar la contraseña
  void _validatePassword(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'\d'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        int userId = await SQLHelper.createUser(
          _usernameController.text,
          _passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario registrado con ID: $userId')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                onChanged: _validatePassword, // Validar en tiempo real
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }
                  if (!_hasMinLength || !_hasUpperCase || !_hasNumber || !_hasSpecialChar) {
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
                  Text(
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
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
