import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../pvp_game.dart';

class JumpButton extends SpriteComponent with HasGameReference<PVPGame>, TapCallbacks {
  final int margin = 32;
  final double buttonSize = 90; // 90 è la width = size del pulsante

  JumpButton() : super(priority: 100);

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    position = Vector2(game.size.x - margin - buttonSize, game.size.y - margin - buttonSize);
    size = Vector2.all(buttonSize);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }
}