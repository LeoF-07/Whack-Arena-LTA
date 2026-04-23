import 'dart:async';
import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:videogame/components/health_bar.dart';
import 'package:videogame/components/jump_button.dart';
import 'package:videogame/components/opponent_controller.dart';
import 'package:videogame/components/pvp_arena.dart';
import 'components/attack_button.dart';
import 'components/character.dart';
import 'components/character_manager.dart';
import 'components/connection.dart';
import 'components/player.dart';
import 'components/utils.dart';

class PVPGame extends FlameGame with DragCallbacks, HasKeyboardHandlerComponents {
  String mode;
  Character character;
  String room;

  PVPGame({this.mode = "", required this.character, required this.room});

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;

  late final Player player;
  late final Player opponent;
  late HealthBar playerHealthBar;
  late HealthBar opponentHealthBar;
  late PVPArena arena;
  late JoystickComponent joystick;
  late int playerNumber;

  late OpponentController opponentController;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages(); // Potrebbe diventare troppo pesante
    player = Player(character: character, isOpponent: false);
    playerHealthBar = HealthBar(maxHealth: player.character.lifePoints, currentHealth: player.character.lifePoints);
    joystick = _createJoystick();

    if(mode == "debug"){
      opponent = Player(character: character, isOpponent: true);
      arena = PVPArena(player1: player, player2: opponent);

      cam = CameraComponent.withFixedResolution(world: arena, width: 640, height: 360);
      cam.priority = 1;
      cam.viewfinder.anchor = Anchor.topLeft;

      Future.delayed(Duration(seconds: 1), () => addAll([cam, arena, joystick, JumpButton(), AttackButton(), playerHealthBar]));
    } else{
      Connection.instance.socket.add(jsonEncode({"message": "wantToPlay", "room": room}));
      _listen();
    }

    return super.onLoad();
  }

  void initGame(int playerNumber, String opponentCharacter) async {
    opponent = Player(character: CharacterManager.instance.characters[opponentCharacter]!, isOpponent: true);
    if(playerNumber == 1){
      arena = PVPArena(player1: player, player2: opponent);
    }else{
      arena = PVPArena(player1: opponent, player2: player);
    }

    cam = CameraComponent.withFixedResolution(world: arena, width: 640, height: 360);
    cam.priority = 1;
    cam.viewfinder.anchor = Anchor.topLeft;

    opponentController = OpponentController();
    opponentHealthBar = HealthBar(maxHealth: opponent.character.lifePoints, currentHealth: opponent.character.lifePoints, opponent: true);

    Future.delayed(Duration(seconds: 1), () => addAll([cam, arena, joystick, JumpButton(), AttackButton(), playerHealthBar, opponentHealthBar]));
  }

  JoystickComponent _createJoystick(){
    return JoystickComponent(
      priority: 100,
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png')),
        size: Vector2.all(40)
      ),
      // knobRadius: Posso personalizzarlo
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
        size: Vector2.all(90)
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32), // Posso togliere il const?
    );
  }

  @override
  void update(double dt){
    _updateJoystick();
    super.update(dt);
  }

  _updateJoystick() {
    switch (joystick.direction){
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void _listen(){
    Connection.instance.broadcast.listen((data) {
        String serverMessage = data.toString();
        _parseMessage(serverMessage);
    });
  }

  void _parseMessage(String serverMessage) async {
    final decodedServerMessage = jsonDecode(serverMessage);
    String message = decodedServerMessage['message'];

    // print(decodedServerMessage);

    switch (message) {
      case "init":
        Connection.instance.socket.add(jsonEncode({'message': 'character', 'character': 'Knight'}));
        break;
      case "prepare":
        initGame(decodedServerMessage['playerNumber'], decodedServerMessage['opponent']);
        break;
      case "snapshot":
        onOpponentSnapshot(decodedServerMessage, opponentController, opponent);
        break;
      case "hurt":
        player.hurt(decodedServerMessage['direction'], decodedServerMessage['damage']);
        break;
      case "hit":
        opponentHealthBar.applyDamage(decodedServerMessage["damage"]);
        break;
      case "gameFinished":
        String result = decodedServerMessage["result"];
        if(result == "lost"){
          player.death();
        }
        break;
    }
  }
}