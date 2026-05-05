import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import '../pvp_game.dart';

class KO extends SpriteComponent with HasGameReference<PVPGame> {
  KO() : super(priority: 1000);

  @override
  Future<void> onLoad() async {
    // Imposta posizione e dimensione
    size = Vector2(200, 100);
    position = Vector2(250, 140);
    // Carica lo sprite
    sprite = Sprite(game.images.fromCache('Items/KO.png'));

    // Inizia invisibile
    opacity = 0;

    // Effetto fade‑in morbido
    add(OpacityEffect.to(
      1,
      EffectController(duration: 1.0, curve: Curves.easeOut),
    ));
  }
}