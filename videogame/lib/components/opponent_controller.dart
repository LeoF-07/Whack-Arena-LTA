import 'package:videogame/components/utils.dart';
import 'package:flame/components.dart';
import 'net_snapshot.dart';

class OpponentController {
  final List<NetSnapshot> snapshots = [];

  void addSnapshot(NetSnapshot s) {
    snapshots.add(s);
    snapshots.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    /*
    if(snapshots.isEmpty || (snapshots.isNotEmpty && s.timestamp > snapshots.last.timestamp)){
      snapshots.add(s);
    }
    */

    // Mantieni solo gli ultimi 20 snapshot
    if (snapshots.length > 20) {
      snapshots.removeAt(0);
    }
  }

  Vector2 getLastPosition(){
    return Vector2(snapshots.last.x, snapshots.last.y);
  }


  // Ora non uso più getInterpolatedPosition()
  final int interpolationDelay = 100; // ms

  Vector2 getInterpolatedPosition() {
    if (snapshots.length < 2) {
      // Non abbiamo abbastanza dati
      return Vector2.zero();
    }

    final int renderTime = DateTime.now().millisecondsSinceEpoch - interpolationDelay;

    // Trova i due snapshot che circondano il renderTime
    NetSnapshot? a;
    NetSnapshot? b;

    for (int i = 0; i < snapshots.length - 1; i++) {
      if (snapshots[i].timestamp <= renderTime &&
          snapshots[i + 1].timestamp >= renderTime) {
        a = snapshots[i];
        b = snapshots[i + 1];
        break;
      }
    }

    // Se non troviamo coppia, usa l'ultimo snapshot
    if (a == null || b == null) {
      final last = snapshots.last;
      return Vector2(last.x, last.y);
    }

    // Calcola t (0 → 1)
    final double t = (renderTime - a.timestamp) / (b.timestamp - a.timestamp);

    final double x = lerp(a.x, b.x, t);
    final double y = lerp(a.y, b.y, t);

    return Vector2(x, y);
  }


}
