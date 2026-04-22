enum Character {
  knight("Knight", 30, 30, 10, 100);

  final String name;
  final double weaponWidth;
  final double weaponHeight;
  final int damage;
  final int lifePoints;

  const Character(this.name, this.weaponWidth, this.weaponHeight, this.damage, this.lifePoints);
}