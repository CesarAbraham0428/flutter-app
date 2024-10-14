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

  Future<bool> login_User(String userName, String? pass) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> user = await db.query(
      'user_app',
      where: 'user_name = ? AND pass = ?',
      whereArgs: [userName, pass],
    );

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
    final id2 =await db.update(
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
    } catch (e) {
      print("Error al eliminar el registro: $e");
}
}
}