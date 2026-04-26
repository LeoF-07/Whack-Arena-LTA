import 'package:mysql_dart/mysql_dart.dart';

class DatabaseService {
  late MySQLConnection conn;

  Future<void> connect(String password) async {
    conn = await MySQLConnection.createConnection(
      host: "192.168.1.101",
      port: 3306,
      userName: "root",
      password: password,
      databaseName: "pvp_game", // optional
    );

    await conn.connect();
  }

  Future<Map<int, String>> getCharacterMap() async {
    final stmt = await conn.prepare('SELECT id, name FROM characters ORDER BY id ASC');
    final results = await stmt.execute([]);

    Map<int, String> map = {};

    for (final row in results.rows) {
      map[int.parse(row.colByName('id').toString())] = row.colByName('name').toString();
    }

    return map;
  }

  Future<void> disconnect() async {
    conn.close();
  }
}