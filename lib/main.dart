//lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/db_helper.dart';
import 'package:flutter_application_2/pages/home_screen.dart';
import 'package:flutter_application_2/pages/login_view.dart';
import 'package:flutter_application_2/pages/register_view.dart';
import 'package:flutter_application_2/pages/admin_home_screen.dart';
import 'package:flutter_application_2/cruds/productos_screen.dart';
import 'package:flutter_application_2/cruds/usuarios_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Realiza la inicialización de la base de datos en Android/iOS sin `sqflite_common_ffi`
    await SQLHelper.createAdminUser(
        "cesar", "cesarabraham0428@gmail.com", "hola");
    await SQLHelper.updateAdminPassword();

    runApp(const MyApp());
  } catch (e) {
    print('Error en la inicialización de la app: $e');
  }
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
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final userId = args?['userId'] as int? ?? 0;
          return HomeScreen(userId: userId);
        },
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
