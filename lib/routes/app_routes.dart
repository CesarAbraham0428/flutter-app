//lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/home_screen.dart';
import 'package:flutter_application_2/pages/login_view.dart';
import 'package:flutter_application_2/pages/register_view.dart';
import 'package:flutter_application_2/pages/admin_home_screen.dart';
import 'package:flutter_application_2/cruds/productos_screen.dart';
import 'package:flutter_application_2/cruds/usuarios_screen.dart';
import 'package:flutter_application_2/pages/product_list_page.dart';
import 'package:flutter_application_2/helpers/http.dart';
import 'package:flutter_application_2/services/product_service.dart';

// Clase para definir y organizar las rutas
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String adminHome = '/adminHome';
  static const String manageProducts = '/manageProducts';
  static const String manageUsers = '/manageUsers';
  static const String productList = '/productList';

  static Map<String, WidgetBuilder> getRoutes({required Http http}) {
    final productService = ProductService(http: http);

    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      home: (context) {
        final args = ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?;
        final userId = args?['userId'] as int? ?? 0;
        return HomeScreen(userId: userId);
      },
      adminHome: (context) => const AdminHomeScreen(),
      manageProducts: (context) => const ProductosScreen(),
      manageUsers: (context) => const UsuariosScreen(),
      productList: (context) => ProductListPage(productService: productService),
    };
  }
}
