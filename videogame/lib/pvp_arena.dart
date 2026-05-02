import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:videogame/components/countdown.dart';
import 'package:videogame/hitboxes/collision_block.dart';
import 'components/indicator.dart';
import 'players/player.dart';

class PVPArena extends World {

  late TiledComponent arena;
  final Player player1;
  final Player player2;
  final int local;
  List<CollisionBlock> collisionsBlocks = [];

  @override
  int priority = 10;

  PVPArena({required this.player1, required this.player2, required this.local});

  @override
  Future<dynamic> onLoad() async {
    arena = await TiledComponent.load('Arena.tmx', Vector2.all(16));
    add(arena);

    final spawnPointsLayer = arena.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if(spawnPointsLayer != null){
      for(final spawnPoint in spawnPointsLayer.objects){
        switch (spawnPoint.class_){ // Le classi sono definite dentro il file .tmx
          case 'Player1':
            player1.position = Vector2(spawnPoint.x, spawnPoint.y);
            Future.delayed(Duration(milliseconds: 800), (){add(player1);});
            if(local == 1){
              showIndicator(spawnPoint.x, spawnPoint.y);
            }
            break;
          case 'Player2':
            player2.position = Vector2(spawnPoint.x, spawnPoint.y);
            Future.delayed(Duration(milliseconds: 800), (){add(player2); player2.flipHorizontallyAroundCenter();});
            if(local == 2){
              showIndicator(spawnPoint.x, spawnPoint.y);
            }
            // add(player2);
            // player2.flipHorizontallyAroundCenter();
            break;
        }
      }
    }

    final collisionsLayer = arena.tileMap.getLayer<ObjectGroup>('Collisions');
    if(collisionsLayer != null){
      for(final collision in collisionsLayer.objects){
        switch (collision.class_){
          case 'Platform':
            final platform = CollisionBlock(
              pos: Vector2(collision.x, collision.y),
              s: Vector2(collision.width, collision.height),
              isPlatform: true
            );
            collisionsBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
                pos: Vector2(collision.x, collision.y),
                s: Vector2(collision.width, collision.height)
            );
            collisionsBlocks.add(block);
            add(block);
            break;
        }
      }

      player1.collisionsBlocks = collisionsBlocks;
      player2.collisionsBlocks = collisionsBlocks; // Non so se serva effettivamente anche al player2 ma meglio tenerlo
    }

    return super.onLoad();
  }

  Future<void> showIndicator(double x, double y) async {
    print("$x, $y");
    final indicator = Indicator(positionX: x, positionY: y);
    final countdown = Countdown();

    Future.delayed(Duration(milliseconds: 1000), () {
      add(indicator);
    });
    Future.delayed(Duration(milliseconds: 3000), () {
      add(countdown);
    });
  }
}