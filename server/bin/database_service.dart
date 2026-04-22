import 'package:mysql_dart/mysql_dart.dart';
import 'character.dart';

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

  Future<List<Character>> getCharacterForServer() async {
    final stmt = await conn.prepare('SELECT id, name, damage, lifePoints, weaponWidth, weaponHeight FROM characters');
    final results = await stmt.execute([]);
    return results.rows.map((row) => Character.fromDb(row)).toList();
  }
  
  Future<List<Map<String, dynamic>>> getCharacterForClient() async {
  final stmt = await conn.prepare('SELECT id, name, description, offsetX, offsetY, width, height, attackVelocity, hurtVelocity, deathVelocity, damage, lifePoints, weaponWidth, weaponHeight FROM characters');

    final result = await stmt.execute([]);

    return result.rows.map((row) {
      return {
        'id': int.parse(row.colAt(0)),
        'name': row.colAt(1),
        'description': row.colAt(2),
        'offsetX': double.parse(row.colAt(3)),
        'offsetY': double.parse(row.colAt(4)),
        'width': double.parse(row.colAt(5)),
        'height': double.parse(row.colAt(6)),
        'attackVelocity': int.parse(row.colAt(7)),
        'hurtVelocity': int.parse(row.colAt(8)),
        'deathVelocity': int.parse(row.colAt(9)),
        'damage': int.parse(row.colAt(10)),
        'lifePoints': int.parse(row.colAt(11)),
        'weaponWidth': double.parse(row.colAt(12)),
        'weaponHeight': double.parse(row.colAt(13))
      };
    }).toList();
  }

  Future<void> disconnect() async {
    conn.close();
  }
}
