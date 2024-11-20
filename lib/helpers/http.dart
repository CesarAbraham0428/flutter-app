import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_method.dart';

typedef Parser<T> = T Function(dynamic data);

class Http {
  final String baseUrl;
  final String? token; // Token de autenticación

  Http({this.baseUrl = '', this.token});

  Future<T> request<T>(
    String path, {
    HttpMethod method = HttpMethod.get,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    required Parser<T> parser,
  }) async {
    Uri url = path.startsWith('http://') || path.startsWith('https://')
        ? Uri.parse(path)
        : Uri.parse('$baseUrl$path');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      url = url.replace(queryParameters: queryParameters);
    }

    // Añadir el token al header si está disponible
    final authHeaders = {
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.get(url, headers: authHeaders);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return parser(jsonDecode(response.body));
    } else {
      throw Exception('Error: ${response.statusCode}, ${response.body}');
    }
  }
}
