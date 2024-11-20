// lib/mail_helper.dart
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailHelper {
  static Future<void> send(
    List<Map<String, dynamic>> cartItems,
    double precioTotal,
    String destino // Correo del usuario
  ) async {
    String username = 'cesarabraham0428@gmail.com';
    String password = 'kbwh zjrr caba kkre';
    final smtpServer = gmail(username, password);

    String itemsHtml = cartItems.map((item) {
      return """
        <tr>
          <td>${item['nombre_product']}</td>
          <td>${item['cantidad']}</td>
          <td>\$${item['precio']}</td>
          <td><img src="${item['imagen']}" width="50" height="50"></td>
        </tr>
      """;
    }).join();

    final message = Message()
      ..from = Address(username, 'Cesar Abraham')
      ..recipients.add(destino)
      ..subject = 'Detalles de tu compra'
      ..html = """
        <h1>Detalle de la compra</h1>
        <table border="1" style="width:100%; text-align:left;">
          <tr>
            <th>Producto</th>
            <th>Cantidad</th>
            <th>Precio</th>
            <th>Imagen</th>
          </tr>
          $itemsHtml
        </table>
        <p><strong>Total de la compra:</strong> \$${precioTotal.toStringAsFixed(2)}</p>
      """;

    try {
      final connection = PersistentConnection(smtpServer);
      await connection.send(message);
      await connection.close();
    } catch (e) {
      print('Error al enviar el correo: $e');
    }
  }
}
