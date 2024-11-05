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

Future<void> main() async {
  // Verifica si estás en un entorno de escritorio y configúralo
  if (isDesktop()) {
    sqfliteFfiInit(); // Inicializa FFI
    databaseFactory =
        databaseFactoryFfi; // Establece el `databaseFactory` global
  }
  // Actualiza la contraseña del administrador "cesar" a una versión encriptada
  await SQLHelper.createAdminUser("cesar", "hola");
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
        '/home': (context) => const HomeScreen(),
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
