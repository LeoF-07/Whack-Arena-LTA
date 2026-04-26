import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:videogame/hitboxes/collision_block.dart';
import 'package:videogame/hitboxes/player_hitbox.dart';
import 'package:videogame/utils.dart';
import 'package:videogame/pvp_game.dart';

import '../characters/character.dart';
import '../connection/connection.dart';

enum PlayerState {idle, running, jumping, falling, attack, hurt, death}

class Player extends SpriteAnimationGroupComponent with HasGameReference<PVPGame>,
                                                        KeyboardHandler{
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  // late final SpriteAnimation jumpingAnimation;
  // late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation attackAnimation;
  late final SpriteAnimation hurtAnimation;
  late final SpriteAnimation deathAnimation;
  final double stepTime = 0.05;
  final Character character;

  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();

  final double gravity = 900;
  final double jumpForce = 310;
  final double terminalVelocity = 500;

  bool isOnGround = false;
  bool hasJumped = false;
  bool hasAttacked = false;
  bool isHurted = false;
  bool isDead = false;
  bool isOpponent;

  List<CollisionBlock> collisionsBlocks = [];
  late PlayerHitbox hitbox = PlayerHitbox(offsetX: character.offsetX, offsetY: character.offsetY, width: character.width, height: character.height);

  Player({required this.character, required this.isOpponent});

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    /*
    Aggiungendo il RectangleHitBox mi aggiunge l'hitbox e con debug = true posso vederlo per poi riadattare anche i valori quando creo l'hitbox
    Vedo una cosa del genere

    * * * * * * * *
    *             *
    *   * * * *   *
    *   *     *   *
    *   *     *   *
    *   * * * *   *
    *             *
    * * * * * * * *

    <-> : offsetX
    */

    anchor = Anchor.center;
    debugMode = false;
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)
    ));
    return super.onLoad();
  }

  @override
  void update(double dt){
    if(!isOpponent){
      _updatePlayerState();
      _updatePlayerMovement(dt);
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _checkVerticalCollisions();
      super.update(dt);

      if(game.mode != "debug"){
        sendSnapshot(Connection.instance.socket, x: x, y: y, vx: velocity.x, vy: velocity.y, facing: scale.x > 0 ? "right" : "left", state: (current as PlayerState).name);
      }
    } else if(isOpponent && game.mode != "debug") {
      /*
      --- PLAYER AVVERSARIO ---
      final pos = game.opponentController.getInterpolatedPosition();
      position = pos;

      Ora la posizione la aggiorno quando arriva ogni snapshot, dopo averli riordinati e preso l'ultimo
      La posizione interpolata è più carina ma causa un grande ritardo
      */

      // Aggiorna animazione in base allo snapshot più recente
      if(game.opponentController.snapshots.isNotEmpty){
        final last = game.opponentController.snapshots.last;
        current = PlayerState.values.byName(last.state);

        // Flip automatico
        if (last.vx < 0 && scale.x > 0) flipHorizontallyAroundCenter();
        if (last.vx > 0 && scale.x < 0) flipHorizontallyAroundCenter();
      }
      
      super.update(dt);
    }
  }


  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;

    final isLeftPressed =
        keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft);

    final isRightPressed =
        keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftPressed ? -1 : 0; // vanno davvero bene questi?
    horizontalMovement += isRightPressed ? 1 : 0;

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space && !isOpponent) {
      hasJumped = true;
    }
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.digit0 && !isOpponent) {
      attack();
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle");
    runningAnimation = _spriteAnimation("Run");
    attackAnimation = _spriteAnimation("Attack")..loop = false;
    hurtAnimation = _spriteAnimation("Hurt")..loop = false;
    deathAnimation = _spriteAnimation("Death")..loop = false;

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: runningAnimation,
      PlayerState.falling: idleAnimation,
      PlayerState.attack: attackAnimation,
      PlayerState.hurt: hurtAnimation,
      PlayerState.death: deathAnimation
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state){
    Image image = game.images.fromCache('Main Characters/${character.name}/$state.png');
    return SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
            amount: (image.width / 96).toInt(),
            stepTime: stepTime,
            textureSize: Vector2.all(96) // 32x32
        )
    );
  }

  void attack(){
    hasAttacked = true;
    current = PlayerState.attack;
    animationTicker?.onComplete = () {
      hasAttacked = false;
    };
  }

  void hurt(String direction, int damage) {
    // direction: +1 = knockback a destra, -1 = knockback a sinistra
    game.playerHealthBar.applyDamage(damage);

    hasAttacked = false; // interrompe eventuale attacco
    isHurted = true;
    // current = PlayerState.hurt;

    // Applica knockback immediato
    if(direction == "right"){
      velocity.x = 200; // puoi regolare la forza
    }
    else{
      velocity.x = -200;
    }
    velocity.y = -200; // piccolo salto all’indietro (opzionale)

    current = PlayerState.hurt;
    animationTicker?.onComplete = () {
      isHurted = false;
      if(isDead){
        current = PlayerState.death;
      }
    };
  }

  void death(){
    isDead = true;
  }

  void _updatePlayerState(){
    // Quando viene chiamata la funzione di flip, Flame moltiplica scale.x per -1
    if(velocity.x < 0 && scale.x > 0){
      flipHorizontallyAroundCenter();
    } else if(velocity.x > 0 && scale.x < 0){
      flipHorizontallyAroundCenter();
    }

    PlayerState playerState = PlayerState.idle;
    if (hasAttacked || isHurted || isDead) {
      return;
    }

    if(isHurted){
      playerState = PlayerState.hurt;
    }
    else if(isDead){
      playerState = PlayerState.death;
    }
    else if(velocity.x != 0) {
      playerState = PlayerState.running;
    }
    else if(velocity.y > gravity) {
      playerState = PlayerState.falling;
    }
    else if(velocity.y < 0) {
      playerState = PlayerState.jumping;
    }


    current = playerState;
  }

  void _updatePlayerMovement(double dt){
    if (hasJumped && isOnGround){ // Altrimenti salterebbe all'infinito
      _playerJump(dt);
    } else{
      hasJumped = false;
    }

    // Interessante vedere cosa succede se commento questa riga.
    // Non posso mettere maggiore di 0 perché la forza di gravità c'è sempre, e sarebbe quindi sempre isOnGround = false
    // Anzi no, penso sia solo per questione di sicurezza. Infatti anche su updatePlayerState() potrei lasciare velocity.y > 0 quando controllo se sta cadendo
    if(velocity.y > gravity) {
      isOnGround = false;
    }

    if(!isHurted){
      velocity.x = horizontalMovement * moveSpeed;
    }
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt){
    velocity.y = -jumpForce; // e qui non serve * dt come nella gravità?
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions(){
    for (final block in collisionsBlocks) {
      //if (!block.isPlatform || (block.isPlatform && velocity.y > 0 && position.y + hitbox.offsetY < block.position.y + block.height)) {
      if(!block.isPlatform){
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.width / 2 - 1;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width / 2 + 1;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt){
    //velocity.y += gravity;
    velocity.y += gravity * dt;
    // Non può andare troppo veloce verso l'alto e fermarsi a terminalVelocity verso il basso
    velocity.y = velocity.y.clamp(-jumpForce, terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionsBlocks) {
      if (block.isPlatform) { // Controllo solo la collisione in discesa
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height / 2 - 1;
            // Senza il -1 a volte cade, non si nota visivamente come il -1 in quella orizzontale per fortuna
            // Potrei anche farlo solo sulle piattaforme e toglierlo dall'altro, perché è il fatto che le piattaforme hanno casi da ignorare e ci passa attraverso
            isOnGround = true;
            break;
          }
        } else{
          // isOnGround = false;
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height / 2 - 1;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height + hitbox.height / 2;
          }
        } else{
          // isOnGround = false;
        }
      }
    }
  }
}