import '../connection/net_snapshot.dart';
import '../connection/opponent_controller.dart';
import 'package:flame/components.dart';

class Opponent extends SpriteComponent with HasGameReference{
  final OpponentController controller;

  Opponent(this.controller)
      : super(size: Vector2(48, 48)); // esempio

  @override
  void update(double dt) {
    super.update(dt);

    // Ottieni la posizione interpolata
    final pos = controller.getInterpolatedPosition();
    position = pos;
  }

  void onServerMessage(Map<String, dynamic> data) {
    controller.addSnapshot(
      NetSnapshot(
        x: data['x'],
        y: data['y'],
        vx: data['vx'],
        vy: data['vy'],
        timestamp: data['timestamp'],
        state: data['state'],
      ),
    );
  }

}
