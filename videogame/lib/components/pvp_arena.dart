import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:videogame/components/collision_block.dart';
import '../components/player.dart';

class PVPArena extends World {

  late TiledComponent arena;
  final Player player1;
  final Player player2;
  List<CollisionBlock> collisionsBlocks = [];

  @override
  int priority = 10;

  PVPArena({required this.player1, required this.player2});

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
            add(player1);
            break;
          case 'Player2':
            player2.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player2);
            player2.flipHorizontallyAroundCenter();
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
}