import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../pvp_game.dart';

class AttackButton extends SpriteComponent with HasGameReference<PVPGame>, TapCallbacks {
  final double buttonSize = 90; // 90 è la width = size del pulsante
  bool disable = false;

  AttackButton() : super(priority: 100);

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    position = Vector2(game.size.x - 32 - buttonSize, game.size.y - 128 - buttonSize);
    size = Vector2.all(buttonSize);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if(!disable){
      disable = true;
      game.player.attack();
      super.onTapDown(event);
      Future.delayed(
          Duration(milliseconds: (game.player.stepTime * game.player.character.attackVelocity * 1000).toInt()),
          () {
            disable = false;
          }
      );
    }
  }
}