import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_2/helpers/http.dart';
import 'package:flutter_application_2/routes/app_routes.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Cargar las configuraciones del archivo .env
  await dotenv.load(fileName: ".env");

  // Inicializar el cliente HTTP con valores del archivo .env
  final http = Http(
    baseUrl: dotenv.env['API_BASE_URL'] ?? 'https://fakestoreapi.com',
    token: dotenv.env['AUTH_TOKEN'],
  );

  runApp(MyApp(http: http));
}

class MyApp extends StatelessWidget {
  final Http http;

  const MyApp({super.key, required this.http});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD Usuarios',
      initialRoute: AppRoutes.login,
      routes: AppRoutes.getRoutes(http: http),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
    );
  }
}
