//lib/db_helper.dart
import 'package:flutter_application_2/encyption_helper.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE user_app(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    user_name TEXT,
    email TEXT,
    pass TEXT,
    createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");

    await database.execute("""CREATE TABLE producto_app(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    nombre_product TEXT,
    precio DOUBLE,
    cantidad_producto INTEGER,
    imagen TEXT,
    createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");

    await database.execute('''CREATE TABLE rol_permiso(
            id INTEGER PRIMARY KEY,
            userId INTEGER,
            rol TEXT,
            FOREIGN KEY (userId) REFERENCES user_app (id) ON DELETE CASCADE
            )''');
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("database_name.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<int> createUser(String user, String email, String? pass) async {
    final db = await SQLHelper.db();
    final hashedPass =
        EncryptionHelper.hashPassword(pass!); // Encripta la contraseña
    final userApp = {
      'user_name': user,
      'email': email,
      'pass':
          hashedPass, // Guarda la contraseña encriptada en el campo correcto
    };
    int userId = await db.insert('user_app', userApp,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    // Asigna el rol de usuario por defecto en rol_permiso
    await db.insert('rol_permiso', {
      'userId': userId,
      'rol': 'usuario',
    });
    return userId;
  }

  static Future<int> createAdminUser(
      String user, String email, String pass) async {
    final db = await SQLHelper.db();
    final hashedPass =
        EncryptionHelper.hashPassword(pass); // Encripta la contraseña

    final userApp = {
      'user_name': user,
      'email': email,
      'pass': hashedPass, // Guarda la contraseña encriptada
    };
    int userId = await db.insert('user_app', userApp,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    await db.insert('rol_permiso', {'userId': userId, 'rol': 'admin'});
    return userId;
  }

  Future<List<String>> getPermissionsForUser(int userId) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> permisoUser = await db.query('rol_permiso',
        columns: ['rol'], where: 'userId = ?', whereArgs: [userId]);

    return List.generate(permisoUser.length, (index) {
      return permisoUser[index]['rol'].toString();
    });
  }

// Verifica las credenciales de inicio de sesión con la contraseña encriptada
  static Future<Map<String, dynamic>?> login_user(
      String nombre, String pass) async {
    final db = await SQLHelper.db();
    final hashedPass =
        EncryptionHelper.hashPassword(pass); // Encripta la contraseña
    List<Map<String, dynamic>> user = await db.query('user_app',
        where: 'user_name = ? AND pass = ?',
        whereArgs: [nombre, hashedPass], // Compara con la contraseña encriptada
        limit: 1);

    return user.isNotEmpty ? user.first : null;
  }

  static Future<List<Map<String, dynamic>>> getAllUser() async {
    final db = await SQLHelper.db();
    return db.query('user_app', orderBy: 'id');
  }

  static Future<String?> getUserEmail(int userId) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> result = await db.query(
      'user_app', // Changed from 'user' to 'user_app'
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['email']; // Changed from 'correo' to 'email'
    }
    return null;
  }

// Actualiza el rol de un usuario existente en la tabla `rol_permiso`
  static Future<void> updateUserRole(int userId, String rol) async {
    final db = await SQLHelper.db();

    // Elimina el rol existente
    await db.delete('rol_permiso', where: 'userId = ?', whereArgs: [userId]);

    // Inserta el nuevo rol
    await db.insert('rol_permiso', {
      'userId': userId,
      'rol': rol,
    });
  }

  static Future<void> updateAdminPassword() async {
    final db = await SQLHelper.db();
    final hashedPass =
        EncryptionHelper.hashPassword("hola"); // Encripta la contraseña "hola"
    await db.update(
      'user_app',
      {'pass': hashedPass},
      where: 'user_name = ?',
      whereArgs: ['cesar'],
    );
  }

  static Future<List<Map<String, dynamic>>> getSingleUser(int id) async {
    final db = await SQLHelper.db();
    return db.query('user_app', where: "id=?", whereArgs: [id], limit: 1);
  }

  // Actualiza un usuario con la contraseña encriptada
  static Future<int> updateUser(
      int id, String nombre, String email, String? pass) async {
    final db = await SQLHelper.db();
    final hashedPass = EncryptionHelper.hashPassword(pass!);
    final userApp = {
      'user_name': nombre,
      'email': email,
      'pass': hashedPass, // Guarda la contraseña encriptada
      'createdAT': DateTime.now().toString()
    };
    return await db.update(
      'user_app',
      userApp,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  static Future<void> deleteUser(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('user_app',
          where: "id = ?", whereArgs: [id]); // Cambié 'user' a 'user_app'
    } catch (e) {}
  }

// Asigna un rol a un usuario en la tabla `rol_permiso`
  Future<void> assignRole(int userId, String rol) async {
    final db = await SQLHelper.db();
    await db.insert('rol_permiso', {
      'userId': userId,
      'rol': rol,
    });
  }

// Métodos para productos

  static Future<List<Map<String, dynamic>>> getAllProductos() async {
    final db = await SQLHelper.db();
    return db.query('producto_app', orderBy: 'id');
  }

  static Future<int> createProducto(String nombre_product, double precio,
      int cantidad_producto, String imagen) async {
    final db = await SQLHelper.db();
    final product = {
      'nombre_product': nombre_product,
      'precio': precio,
      'cantidad_producto': cantidad_producto,
      'imagen': imagen,
    };
    return await db.insert('producto_app', product,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<int> updateProducto(int id, String nombre_product,
      double precio, int cantidad_producto, String imagen) async {
    final db = await SQLHelper.db();
    final product = {
      'nombre_product': nombre_product,
      'precio': precio,
      'cantidad_producto': cantidad_producto,
      'imagen': imagen,
      'createdAT': DateTime.now().toString()
    };
    return await db.update(
      'producto_app',
      product,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  static Future<void> deleteProducto(int id) async {
    final db = await SQLHelper.db();
    await db.delete('producto_app', where: "id = ?", whereArgs: [id]);
  }
}
