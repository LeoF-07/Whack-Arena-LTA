import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;
  CollisionBlock({pos, s, this.isPlatform = false}) : super(position: pos, size: s) {debugMode = false;}
}