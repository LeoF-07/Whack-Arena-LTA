import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'character_manager.dart';
import 'character.dart';

class GameSession{
  GameSession({required this.socket1, required this.socket2, required this.broadcast1, required this.broadcast2}){
    startGame();
  }

  WebSocket socket1;
  WebSocket socket2;
  Stream broadcast1;
  Stream broadcast2;

  int readyPlayers = 0;

  List<WebSocket> sockets = [];
  List<Character> characters = [CharacterManager.instance.characters["Knight"]!, CharacterManager.instance.characters["Knight"]!];

  List<int> healths = [0, 0];

  List<Map<String, dynamic>> lastSnapshots = [
    {
      "message": "snapshot",
      "x": 0,
      "y": 0,
      "vx": 0,
      "vy": 0,
      "facing": "rigth",
      "state": 0,
      "timestamp": 0,
    },
    {
      "message": "snapshot",
      "x": 0,
      "y": 0,
      "vx": 0,
      "vy": 0,
      "facing": "rigth",
      "state": 0,
      "timestamp": 0,
    }
  ];

  List<bool> canAttack = [true, true];

  void checkAttack(int player){
    if(canAttack[player]){
      canAttack[player] = false;

      double lastXPlayer = lastSnapshots[player]["x"];
      double lastYPlayer = lastSnapshots[player]["y"];
      String playerFacing = lastSnapshots[player]["facing"];
      double lastXOpponent = lastSnapshots[(player + 1) % 2]["x"];
      double lastYOpponent = lastSnapshots[(player + 1) % 2]["y"];

      print("$lastXOpponent, $lastXPlayer, $playerFacing");

      if((playerFacing == "right" && (lastXOpponent >= lastXPlayer && lastXOpponent <= lastXPlayer + 30 && lastYOpponent >= lastYPlayer - 30 && lastYOpponent <= lastYPlayer + 30))
          ||
         (playerFacing == "left" && (lastXOpponent <= lastXPlayer && lastXOpponent >= lastXPlayer - 30 && (lastYOpponent >= lastYPlayer - 30 && lastYOpponent <= lastYPlayer + 30)))
      ){
        print("Hit");
        //int damage = CharacterManager.instance.characters[characters[player]]!.damage;
        int damage = characters[player].damage;
        sockets[(player + 1) % 2].add(jsonEncode({"message": "hurt", "direction": playerFacing, "damage": damage}));
        sockets[player].add(jsonEncode({"message": "hit", "damage": damage}));
        healths[(player + 1) % 2] -= damage;

        if(healths[(player + 1) % 2] <= 0){
          sockets[(player + 1) % 2].add(jsonEncode({"message": "gameFinished", "result": "lost"}));
          sockets[player].add(jsonEncode({"message": "gameFinished", "result": "won"}));
        }
      }

      Future.delayed(Duration(milliseconds: (0.05 * characters[player].attackVelocity * 1000).toInt()), () => canAttack[player] = true);
    }
  }

  void forwardSnapshot(int player, Map<String, dynamic> data) {
    if(data["timestamp"] < (lastSnapshots[player]["timestamp"] as int)){
      return;
    }
    final snapshot = {
      "message": "snapshot",
      "x": data["x"],
      "y": data["y"],
      "vx": data["vx"],
      "vy": data["vy"],
      "facing": data["facing"],
      "state": data["state"],
      "timestamp": data["timestamp"],
    };
    lastSnapshots[player] = snapshot;
    sockets[(player + 1) % 2].add(jsonEncode(snapshot));
  }

  void listen(Stream broadcast, int player){
    broadcast.listen((data) {
      // print(data);
      final decodedMessage = jsonDecode(data);
      if(decodedMessage['message'] == "character"){
        String character = decodedMessage['character'];
        characters[player] = CharacterManager.instance.get(character);
        healths[player] = characters[player].lifePoints;
        readyPlayers++;
      }
      if(decodedMessage['message'] == "character" && readyPlayers == 2){
        int playerNumber = Random().nextInt(2);
        String initFirst = jsonEncode({'message': 'prepare', 'playerNumber': playerNumber, 'opponent': characters[0].name});
        String initSecond = jsonEncode({'message': 'prepare', 'playerNumber': (playerNumber + 1) % 2, 'opponent': characters[1].name});
        socket1.add(initFirst);
        socket2.add(initSecond);
        readyPlayers = 0;
      }
      if (decodedMessage["message"] == "snapshot") {
        forwardSnapshot(player, decodedMessage);
      }
      if (decodedMessage["state"] == "attack"){
        checkAttack(player);
      }
      if(decodedMessage["message"] == "ready"){
        readyPlayers++;
      }
      if(decodedMessage["message"] == "ready" &&  readyPlayers == 2){
        socket1.add(jsonEncode({"message": "go"}));
        socket2.add(jsonEncode({"message": "go"}));
        readyPlayers = 0;
      }
    });
  }

  void startGame(){
    socket1.add(jsonEncode({'message': 'init'}));
    socket2.add(jsonEncode({'message': 'init'}));

    sockets.add(socket1);
    sockets.add(socket2);

    listen(broadcast1, 0);
    listen(broadcast2, 1);
  }
}