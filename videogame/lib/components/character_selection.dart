import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:videogame/components/character_manager.dart';
import '../pvp_game.dart';
import 'package:flame/game.dart';
import 'character.dart';
import 'connection.dart';

class CharacterSelection extends StatefulWidget {
  const CharacterSelection({super.key});

  @override
  State<CharacterSelection> createState() => CharacterSelectionState();
}

class CharacterSelectionState extends State<CharacterSelection> {
  late List<Character> characters;
  late Character selectedCharacter = CharacterManager.instance.characters["Knight"]!;
  late StreamSubscription socketSub;
  late String room;
  final TextEditingController roomController = TextEditingController();

  @override
  void initState() {
    characters = CharacterManager.instance.characters.values.toList();
    super.initState();
  }

  void sendCreateRoom() {
    Connection.instance.socket.add(jsonEncode({"message": "createRoom"}));
    socketSub = Connection.instance.broadcast.listen((data) {
      String serverMessage = data.toString();
      print(serverMessage);
      final decodedServerMessage = jsonDecode(serverMessage);
      String message = decodedServerMessage['message'];
      if(message == "room"){
        String room = decodedServerMessage["room"];

        setState(() {
          roomController.text = room;
        });
        socketSub.cancel();
      }
    });
  }

  void sendJoinRoom() {
    final code = roomController.text.trim();
    if (code.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameWidget(
          game: PVPGame(character: CharacterManager.instance.characters["Knight"]!, room: roomController.text),
          autofocus: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // -------------------------
          // 🟦 COLONNA SINISTRA: PERSONAGGI
          // -------------------------
          Expanded(
            flex: 2,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                Character character = characters[index];

                return GestureDetector(
                  onTap: () {
                    setState((){selectedCharacter = character;});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedCharacter.name == character.name
                            ? Colors.green
                            : Colors.blueGrey.shade900,
                        width: 3,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        character.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // -------------------------
          // 🟩 COLONNA DESTRA: MATCHMAKING
          // -------------------------
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.grey.shade900,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Matchmaking",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🔵 CREATE ROOM
                  ElevatedButton(
                    onPressed: sendCreateRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text(
                      "Create Room",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🔵 JOIN ROOM
                  TextField(
                    controller: roomController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Room Code",
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: sendJoinRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text(
                      "Join Room",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:prova_videogame/components/character_manager.dart';
import '../pvp_game.dart';
import 'package:flame/game.dart';
import 'character.dart';

class CharacterSelection extends StatefulWidget{
  const CharacterSelection({super.key});

  @override
  State<CharacterSelection> createState() => CharacterSelectionState();
}

class CharacterSelectionState extends State<CharacterSelection>{
  late List<Character> characters;

  @override
  void initState() {
    characters = CharacterManager.instance.characters.values.toList();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,          // 2 colonne
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,      // proporzioni più gradevoli
        ),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          Character character = characters[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameWidget(
                    game: PVPGame(character: character),
                    autofocus: true,
                  ),
                )
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  character.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}

 */