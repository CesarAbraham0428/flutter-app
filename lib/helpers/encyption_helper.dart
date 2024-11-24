//lib\helpers\encyption_helper.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionHelper {
  static String hashPassword(String password) {
    final bytes = utf8.encode(password); // Convierte la contraseña a bytes
    final digest = sha256.convert(bytes); // Genera el hash SHA-256
    return digest.toString(); // Devuelve la contraseña encriptada como cadena
  }
}
