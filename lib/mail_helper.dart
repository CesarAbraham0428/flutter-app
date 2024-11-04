import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailHelper {
  static Future<void> send(
    String nombreProducto,
    String imagenUrl,
    int cantidadComprada,
    double precioTotal,
  ) async {
    // Configuración del correo
    String username = 'cesarabraham0428@gmail.com';
    String password = 'kbwh zjrr caba kkre';
    String destino = 'lopezcesar0428@gmail.com';
    final smtpServer = gmail(username, password);

    // Crear el mensaje
    final message = Message()
      ..from = Address(username, 'Cesar Abraham')
      ..recipients.add(destino)
      ..subject = 'Detalle de la compra: $nombreProducto'
      ..text = 'Has comprado $cantidadComprada unidades de $nombreProducto por un total de \$${precioTotal.toStringAsFixed(2)}.'
      ..html = """
        <h1>Detalle de la compra</h1>
        <p><strong>Producto:</strong> $nombreProducto</p>
        <p><strong>Cantidad:</strong> $cantidadComprada</p>
        <p><strong>Precio total:</strong> \$${precioTotal.toStringAsFixed(2)}</p>
        <p><strong>Imagen del producto:</strong></p>
        <img src="$imagenUrl" alt="$nombreProducto" style="max-width: 300px;">
      """;

    // Enviar el correo
    try {
      final connection = PersistentConnection(smtpServer);
      await connection.send(message);
      await connection.close();
    } catch (e) {
      print('Error al enviar el correo: $e');
    }
  }
}
