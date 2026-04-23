import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:ui';

class BackArrow extends SpriteComponent with TapCallbacks {
  final VoidCallback onPressed;

  BackArrow(Sprite sprite, this.onPressed) : super(
    sprite: sprite,
    size: Vector2(64, 64),
    position: Vector2(30, 30),
    priority: 200,
  );

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }
}