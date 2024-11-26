import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaypalService {
  static String get clientId => dotenv.env['Client_ID'] ?? '';
  static String get clientSecret => dotenv.env['Client_Secret'] ?? '';
  static String get sandboxUrl => 'https://api.sandbox.paypal.com';
  
  static bool get sandbox => true; // Set to false for production
  
  static String get currency => 'USD';
}