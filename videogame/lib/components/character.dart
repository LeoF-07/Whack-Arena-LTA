class Character {
  final int id;
  final String name;
  final String description;
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;
  final int attackVelocity;
  final int hurtVelocity;
  final int deathVelocity;
  final int damage;
  final int lifePoints;
  final double weaponWidth;
  final double weaponHeight;

  Character({
    required this.id,
    required this.name,
    required this.description,
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
    required this.attackVelocity,
    required this.hurtVelocity,
    required this.deathVelocity,
    required this.damage,
    required this.lifePoints,
    required this.weaponWidth,
    required this.weaponHeight,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      offsetX: json['offsetX'],
      offsetY: json['offsetY'],
      width: json['width'],
      height: json['height'],
      attackVelocity: json['attackVelocity'],
      hurtVelocity: json['hurtVelocity'],
      deathVelocity: json['deathVelocity'],
      damage: json['damage'],
      lifePoints: json['lifePoints'],
      weaponWidth: json['weaponWidth'],
      weaponHeight: json['weaponHeight']
    );
  }
}