//lib/db_helper.dart
import 'dart:ffi';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE user_app(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    user_name TEXT,
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
            FOREIGN KEY (userId) REFERENCES user_app (id)
            )''');
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("database_name.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  Future<List<String>> getPermissionsForUser(int userId) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> permisoUser = await db.query('rol_permiso',
        columns: ['rol'], where: 'userId = ?', whereArgs: [userId]);

    return List.generate(permisoUser.length, (index) {
      return permisoUser[index]['rol'].toString();
    });
  }

  static Future<int> createUser(String user, String? pass) async {
    final db = await SQLHelper.db();
    final userApp = {
      'user_name': user,
      'pass': pass
    }; // Cambié 'user' a 'user_name'
    final id = await db.insert('user_app', userApp,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<bool> login_user(String nombre, String pass) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> user = await db.query('user_app',
        where: 'user_name = ? AND pass = ?',
        whereArgs: [nombre, pass],
        limit: 1);

    return user.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getAllUser() async {
    final db = await SQLHelper.db();
    return db.query('user_app', orderBy: 'id'); // Cambié 'user' a 'user_app'
  }

  static Future<List<Map<String, dynamic>>> getSingleUser(int id) async {
    final db = await SQLHelper.db();
    return db.query('user_app',
        where: "id=?", whereArgs: [id], limit: 1); // Cambié 'user' a 'user_app'
  }

  static Future<int> updateUser(int id, String nombre, String? desc) async {
    final db = await SQLHelper.db();
    final userApp = {
      'user_name': nombre,
      'pass': desc,
      'createdAT': DateTime.now().toString()
    };
    final id2 = await db.update(
      'user_app',
      userApp,
      where: "id = ?",
      whereArgs: [id],
    );
    return id2;
  }

  static Future<void> deleteUser(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('user_app',
          where: "id = ?", whereArgs: [id]); // Cambié 'user' a 'user_app'
    } catch (e) {}
  }

// Métodos para productos

  static const urlProducto =
      "https://http2.mlstatic.com/D_NQ_NP_926115-MLA54902631714_042023-O.webp";

  static Future<List<Map<String, dynamic>>> getAllProductos() async {
    final db = await SQLHelper.db();
    return db.query('producto_app', orderBy: 'id');
  }

  static Future<int> createProductos(String nombre_product, Double precio,
      Int cantidad_producto, String imagen) async {
    final db = await SQLHelper.db();
    final userApp = {
      'nombre_product': nombre_product,
      'precio': precio,
      'cantidad_producto': 1,
      'imagen': urlProducto,
    };
    final id = await db.insert('producto_app', userApp,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> updateProducto(int id, String nombre_product,
      Double precio, Int cantidad_producto, String imagen) async {
    final db = await SQLHelper.db();
    final userApp = {
      'nombre_product': nombre_product,
      'precio': precio,
      'cantidad_producto': 1,
      'imagen': urlProducto,
      'createdAT': DateTime.now().toString()
    };
    final id2 = await db.update(
      'producto_app',
      userApp,
      where: "id = ?",
      whereArgs: [id],
    );
    return id2;
  }

  static Future<void> deleteProducto(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('producto_app',
          where: "id = ?", whereArgs: [id]);
    } catch (e) {}
  }
}