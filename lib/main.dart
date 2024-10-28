//lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';
import 'package:flutter_application_2/home_screen.dart';
import 'package:flutter_application_2/login_view.dart';
import 'package:flutter_application_2/register_view.dart';
import 'package:flutter_application_2/admin_home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importa la biblioteca para soporte FFI
import 'package:flutter_application_2/productosScreen.dart';
import 'package:flutter_application_2/usuariosScreen.dart';

Future<void> main() async {
  // Verifica si estás en un entorno de escritorio y configúralo
  if (isDesktop()) {
    sqfliteFfiInit(); // Inicializa FFI
    databaseFactory =
        databaseFactoryFfi; // Establece el `databaseFactory` global
  }
  // Crear usuario admin (esto es temporal, solo para la inserción inicial)
  await SQLHelper.createAdminUser("cesar", "hola");
  runApp(const MyApp());
}

bool isDesktop() {
  // Función para verificar si estamos en un entorno de escritorio
  return !identical(
      0, 0.0); // Hack para detectar si se ejecuta en Flutter Desktop
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Usuarios',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomeScreen(),
        '/adminHome': (context) => const AdminHomeScreen(),
        '/manageProducts': (context) => const ManageProductsScreen(),
        '/manageUsers': (context) => const ManageUsersScreen(),
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      //home: HomeScreen(),
    );
  }
}
