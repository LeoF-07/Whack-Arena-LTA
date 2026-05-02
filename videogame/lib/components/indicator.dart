import 'dart:math';
import 'dart:async';
import 'package:flame/components.dart';
import '../pvp_game.dart';

class Indicator extends SpriteComponent with HasGameReference<PVPGame> {
  final double indicatorSize = 90;
  final double positionX;
  final double positionY;

  double elapsed = 0;          // tempo passato
  final double amplitude = 10; // quanto si muove su/giù
  final double speed = 3;      // velocità dell’oscillazione

  late double baseY;           // posizione verticale di partenza

  Indicator({
    required this.positionX,
    required this.positionY,
  }) : super(priority: 1000);

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('Items/Indicator.png'));

    // Posizione iniziale (come la tua)
    position = Vector2(positionX - 45, positionY - 30);

    // Salviamo la Y di partenza per oscillare attorno a quella
    baseY = position.y;

    size = Vector2.all(indicatorSize);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    elapsed += dt;

    // Movimento su-giù con sinusoide
    position.y = baseY + sin(elapsed * speed) * amplitude;
  }
}


/*
import 'dart:async';
import 'package:flame/components.dart';
import '../pvp_game.dart';

class Indicator extends SpriteComponent with HasGameReference<PVPGame> {
  final double indicatorSize = 90; // 90 è la width = size del pulsante
  final double positionX;
  final double positionY;

  Indicator({required this.positionX, required this.positionY}) : super(priority: 1000);

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('Items/Indicator.png'));
    position = Vector2(positionX - 45, positionY - 40);
    size = Vector2.all(indicatorSize);
    return super.onLoad();
  }
}
*/