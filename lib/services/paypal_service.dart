//lib\services\paypal_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaypalService {
  static String get clientId => dotenv.env['Client_ID'] ?? '';
  static String get clientSecret => dotenv.env['Client_Secret'] ?? '';
  static String get sandboxUrl => 'https://api.sandbox.paypal.com';
  static String get currency => 'USD';

  // URLs
  static String get returnURL => "https://success.example.com";
  static String get cancelURL => "https://cancel.example.com";

  Future<String?> getAccessToken() async {
    final response = await http.post(
      Uri.parse('$sandboxUrl/v1/oauth2/token'),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'];
    } else {
      throw Exception('Error al obtener token: ${response.body}');
    }
  }

  Future<String?> createPayment(double total) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    final paymentData = {
      "intent": "sale",
      "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL},
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {"total": total.toStringAsFixed(2), "currency": currency},
          "description": "Compra de productos"
        }
      ]
    };

    final response = await http.post(
      Uri.parse('$sandboxUrl/v1/payments/payment'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(paymentData),
    );

    if (response.statusCode == 201) {
      final links = jsonDecode(response.body)['links'];
      final approvalUrl =
          links.firstWhere((link) => link['rel'] == 'approval_url')['href'];
      return approvalUrl;
    } else {
      throw Exception('Error al crear pago: ${response.body}');
    }
  }
}
