import 'dart:convert';
import 'dart:io';
import 'package:videogame/hitboxes/collision_block.dart';
import 'package:videogame/players/player.dart';
import 'connection/net_snapshot.dart';
import 'connection/opponent_controller.dart';

/*
enum Character{
  samurai("Samurai", 38, 45, 26, 38, 5),
  knight("Knight", 32, 32, 32, 32, 5);

  final String name;
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;
  final int attackVelocity;

  const Character(this.name, this.offsetX, this.offsetY, this.width, this.height, this.attackVelocity);
}
*/

bool checkCollision(Player player, CollisionBlock block){
  final hitbox = player.hitbox;

  final playerX = player.position.x - (player.width / 2 - hitbox.offsetX);
  final playerY = player.position.y - (player.height / 2 - hitbox.offsetY);
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.position.x;
  final blockY = block.position.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  if(block.isPlatform && (((playerY < blockY + blockHeight) && (playerY > blockY))
                      || ((playerY < blockY) && (playerY + playerHeight > blockY + blockHeight))
                      || ((playerY + playerHeight < blockY + blockHeight) && (playerY + playerHeight > blockY + blockHeight / 3)))){
    return false;
  }

  return (
      playerY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      playerX < blockX + blockWidth &&
      playerX + playerWidth > blockX
  );
}

void sendSnapshot(WebSocket socket, {required double x, required double y, required double vx, required double vy, required String facing, required String state}) {
  final msg = {
    "message": "snapshot",
    "x": x,
    "y": y,
    "vx": vx,
    "vy": vy,
    "facing": facing,
    "state": state,
    "timestamp": DateTime.now().millisecondsSinceEpoch,
  };

  socket.add(jsonEncode(msg));
}

void onOpponentSnapshot(data, OpponentController opponentController, Player opponent) {
  opponentController.addSnapshot(
    NetSnapshot(
      x: data['x'],
      y: data['y'],
      vx: data['vx'],
      vy: data['vy'],
      timestamp: data['timestamp'],
      state: data['state'],
    ),
  );

  // addSnapshot li riordina anche

  opponent.position = opponentController.getLastPosition();
}

double lerp(double a, double b, double t) {
  return a + (b - a) * t;
}