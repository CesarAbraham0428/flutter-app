//lib/login_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/helpers/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword =
      true; // Variable para controlar la visibilidad de la contraseña

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Verificar las credenciales
    final user = await SQLHelper.login_user(username, password);
    if (user != null) {
      int userId = user['id'];

      // Guardar el userId en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);

      // Verificar rol del usuario para redirigir correctamente
      List<String> roles = await SQLHelper().getPermissionsForUser(userId);
      if (roles.contains('admin')) {
        Navigator.pushReplacementNamed(context, '/adminHome');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText:
                    _obscurePassword, // Usamos la variable para ocultar o mostrar la contraseña
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword; // Cambiar el estado de visibilidad
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Iniciar sesión'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic>? user = await SQLHelper.login_user(
        _usernameController.text,
        _passwordController.text,
      );

      if (user != null) {
        int userId = user['id'];
        List<String> roles = await SQLHelper().getPermissionsForUser(userId);

        if (roles.contains('admin')) {
          Navigator.pushReplacementNamed(context, '/adminHome');
        }

        if (roles.contains('usuario')) {
          Navigator.pushReplacementNamed(context, '/home',
              arguments: {'userId': userId});
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos')),
        );
      }
    }
  }
}
