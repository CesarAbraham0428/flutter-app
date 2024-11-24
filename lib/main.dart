import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_2/helpers/http.dart';
import 'package:flutter_application_2/routes/app_routes.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktop()) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Cargar las configuraciones del archivo .env
  await dotenv.load(fileName: ".env");

  // Inicializar el cliente HTTP con valores del archivo .env
  final http = Http(
    baseUrl: dotenv.env['API_BASE_URL'] ?? 'https://default-url.com',
    token: dotenv.env['AUTH_TOKEN'] ?? 'default-token',
  );

  runApp(MyApp(http: http));
}

bool isDesktop() {
  return !identical(0, 0.0); // Hack para detectar Flutter Desktop
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
