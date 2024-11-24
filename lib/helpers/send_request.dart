// lib\helpers\send_request.dart
import 'package:http/http.dart' as http;
import 'http_method.dart';

Future<http.Response> sendRequest({
  required Uri url,
  required HttpMethod method,
  required Map<String, String> headers,
  dynamic body,
}) async {
  switch (method) {
    case HttpMethod.get:
      return await http.get(url, headers: headers);
    case HttpMethod.post:
      return await http.post(url, headers: headers, body: body);
    default:
      throw Exception('Unsupported HTTP method');
  }
}
