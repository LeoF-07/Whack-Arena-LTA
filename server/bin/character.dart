import 'package:mysql_dart/mysql_dart.dart';

class Character {
  final int id;
  final String name;
  final double weaponWidth;
  final double weaponHeight;
  final int damage;
  final int lifePoints;

  Character({
    required this.id,
    required this.name,
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
    id: int.parse(row.colAt(0)),
    name: row.colAt(1),
    weaponWidth: double.parse(row.colAt(4)),
    weaponHeight: double.parse(row.colAt(5)),
    damage: int.parse(row.colAt(2)),
    lifePoints: int.parse(row.colAt(3)),
  );
}

}
