import 'dart:async';
import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../connection/connection.dart';
import '../pvp_game.dart';

class Countdown extends SpriteComponent with HasGameReference<PVPGame> {
  late Timer countdownTimer;
  late StreamSubscription socketSub;
  int currentIndex = 0;

  // Coordinate dei singoli frame nel tuo sprite sheet
  final List<Vector2> framePositions = [
    Vector2(150, 120),     // 3
    Vector2(590, 120),    // 2
    Vector2(1030, 120),   // 1
    Vector2(560, 560),   // Whack!
  ];

  final List<Vector2> itemsSize = [
    Vector2(350, 350),
    Vector2(530, 340)
  ];

  Countdown() : super(priority: 1000);

  @override
  Future<void> onLoad() async {
    size = Vector2.all(90);
    position = Vector2(250, 140);
    sprite = Sprite(
      game.images.fromCache('Items/Countdown.png'),
      srcPosition: framePositions[0],
      srcSize: itemsSize[0],
    );

    // Effetto fade‑in iniziale
    add(OpacityEffect.to(1, EffectController(duration: 0.4)));

    // Timer per cambiare immagine ogni secondo
    countdownTimer = Timer(1, repeat: true, onTick: _nextFrame);
    countdownTimer.start();
  }

  void _nextFrame() {
    currentIndex++;

    if (currentIndex < framePositions.length - 1) {
      sprite = Sprite(
        game.images.fromCache('Items/Countdown.png'),
        srcPosition: framePositions[currentIndex],
        srcSize: itemsSize[0],
      );

      // Applica fade‑in ad ogni cambio
      opacity = 0;
      add(OpacityEffect.to(1, EffectController(duration: 0.4)));
    } else {
      countdownTimer.stop();

      Connection.instance.socket.add(jsonEncode({"message": "ready"}));
      socketSub = Connection.instance.broadcast.listen((data) {
        String serverMessage = data.toString();
        final decodedServerMessage = jsonDecode(serverMessage);
        String message = decodedServerMessage['message'];
        if(message == "go"){
          size = Vector2(130, 90);
          sprite = Sprite(
            game.images.fromCache('Items/Countdown.png'),
            srcPosition: framePositions.last,
            srcSize: itemsSize[1],
          );
          Future.delayed(Duration(seconds: 1), () {
            removeFromParent();
            game.canMove = true;
          });
          socketSub.cancel();
        }
      });
    }
  }

  /*
  void _nextFrame() {
    currentIndex++;

    if (currentIndex < framePositions.length) {
      // Aggiorna sprite
      Vector2 srcSize = itemsSize[0];
      if(currentIndex == 3){
        srcSize = itemsSize[1];
        size = Vector2(130, 90);
      }
      sprite = Sprite(
        game.images.fromCache('Items/Countdown.png'),
        srcPosition: framePositions[currentIndex],
        srcSize: srcSize,
      );

      // Applica fade‑in ad ogni cambio
      opacity = 0;
      add(OpacityEffect.to(1, EffectController(duration: 0.4)));
    } else {
      countdownTimer.stop();
      Future.delayed(const Duration(seconds: 1), () => removeFromParent());
    }
  }
  */

  @override
  void update(double dt) {
    super.update(dt);
    countdownTimer.update(dt);
  }
}