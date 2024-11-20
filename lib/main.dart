import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_2/helpers/http.dart';
import 'package:flutter_application_2/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar las configuraciones del archivo .env
  await dotenv.load(fileName: ".env");

  // Inicializar el cliente HTTP con la URL base y el token del archivo .env
  final http = Http(
    baseUrl: dotenv.env['API_BASE_URL'] ?? '',
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
