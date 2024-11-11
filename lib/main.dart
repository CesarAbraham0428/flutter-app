//lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';
import 'package:flutter_application_2/pages/home_screen.dart';
import 'package:flutter_application_2/pages/login_view.dart';
import 'package:flutter_application_2/pages/register_view.dart';
import 'package:flutter_application_2/pages/admin_home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importa la biblioteca para soporte FFI
import 'package:flutter_application_2/cruds/productos_screen.dart';
import 'package:flutter_application_2/cruds/usuarios_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // Verifica si estás en un entorno de escritorio y configúralo
  if (isDesktop()) {
    sqfliteFfiInit(); // Inicializa FFI
    databaseFactory = databaseFactoryFfi; // Establece el `databaseFactory` global
  }
  // Actualiza la contraseña del administrador "cesar" a una versión encriptada
  await SQLHelper.createAdminUser("cesar", "hola", "admin@gmail.com");
  await SQLHelper.updateAdminPassword();
  runApp(const MyApp());
}

bool isDesktop() {
  // Función para verificar si estamos en un entorno de escritorio
  return !identical(
      0, 0.0); // Hack para detectar si se ejecuta en Flutter Desktop
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Widget raiz de la aplicación
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD Usuarios',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
       '/home': (context) => FutureBuilder<int?>(
              future: _getUserId(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Pantalla de carga
                } else if (snapshot.hasData && snapshot.data != null) {
                  return HomeScreen(userId: snapshot.data!);
                } else {
                  return const LoginPage(); // Si no hay userId, redirige a login
                }
              },
            ),
        '/adminHome': (context) => const AdminHomeScreen(),
        '/manageProducts': (context) => const ProductosScreen(),
        '/manageUsers': (context) => const UsuariosScreen(),
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
    );
  }
}
