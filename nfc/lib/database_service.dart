import 'dart:convert';
import 'package:crypto/crypto.dart';
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

  Future<Map<String, int>> getCharacterMap() async {
    final stmt = await conn.prepare('SELECT id, name FROM characters ORDER BY id ASC');
    final results = await stmt.execute([]);

    Map<String, int> map = {};

    for (final row in results.rows) {
      map[row.colByName('name').toString()] = int.parse(row.colByName('id').toString());
    }

    return map;
  }

  String hashCodeString(String code) {
    final bytes = utf8.encode(code);
    return sha256.convert(bytes).toString();
  }

  Future<bool> searchDuplicated(String code) async {
    final codeHash = hashCodeString(code);
    final stmt = await conn.prepare('SELECT COUNT(*) AS cnt FROM codes WHERE code_hash = ?');
    final results = await stmt.execute([codeHash]);

    final row = results.rows.first;
    final count = int.parse(row.colByName('cnt'));

    return (count > 0);
  }

  Future<void> addCode(int characterID, String code) async {
    final codeHash = hashCodeString(code);

    try {
      final stmt = await conn.prepare('INSERT INTO codes (code_hash, character_id) VALUES (?, ?)');

      await stmt.execute([codeHash, characterID]);
    } catch (e) {
      // Errore di chiave duplicata → codice già presente
      if (e.toString().contains('Duplicate') ||
          e.toString().contains('UNIQUE') ||
          e.toString().contains('PRIMARY')) {
        return;
      }

      // Altri errori → rilancia
      rethrow;
    }
  }

  Future<void> unlockAllTags() async {
    final stmt = await conn.prepare('UPDATE codes SET used = 0, used_at = null');
    await stmt.execute([]);
  }

  Future<void> disconnect() async {
    conn.close();
  }
}