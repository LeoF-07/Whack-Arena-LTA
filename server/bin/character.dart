import 'package:mysql_dart/mysql_dart.dart';

class Character {
  final int id;
  final String name;
  final int attackVelocity;
  final double weaponWidth;
  final double weaponHeight;
  final int damage;
  final int lifePoints;

  Character({
    required this.id,
    required this.name,
    required this.attackVelocity,
    required this.weaponWidth,
    required this.weaponHeight,
    required this.damage,
    required this.lifePoints,
  });

  /*
  factory Character.fromDb(Map<String, dynamic> row) {
    return Character(
      name: row['name'],
      weaponWidth: row['weaponWidth'],
      weaponHeight: row['weaponHeight'],
      damage: row['damage'],
      lifePoints: row['lifePoints'],
    );
  }
  */

  factory Character.fromDb(ResultSetRow row) {
  return Character(
    id: int.parse(row.colByName("id")),
    name: row.colByName("name"),
    attackVelocity: int.parse(row.colByName("attackVelocity")),
    weaponWidth: double.parse(row.colByName("weaponWidth")),
    weaponHeight: double.parse(row.colByName("weaponHeight")),
    damage: int.parse(row.colByName("damage")),
    lifePoints: int.parse(row.colByName("lifePoints")),
  );
}

}
