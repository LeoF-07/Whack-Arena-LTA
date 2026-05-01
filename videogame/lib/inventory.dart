import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:videogame/characters/character_manager.dart';
import 'characters/character.dart';
import 'connection/connection.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => InventoryState();
}

class InventoryState extends State<Inventory> {
  late List<Character> characters;
  late Character selectedCharacter = CharacterManager.instance.characters["Knight"]!;
  late StreamSubscription socketSub;
  String nfcReadText = "";

  @override
  void initState() {
    characters = CharacterManager.instance.characters.values.toList();
    super.initState();
  }

  Future<void> lockCharacters() async {
    await CharacterManager.instance.lockCharacters();
    setState(() {});
  }

  Future<void> readNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) return;

    final completer = Completer<bool>();

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final nfcA = NfcA.from(tag);
          if (nfcA == null) {
            NfcManager.instance.stopSession(errorMessage: "Tag non supportato");
            completer.complete(false);
            return;
          }

          List<int> buffer = [];

          // Legge dalla pagina 4 alla 7 (16 byte)
          for (int page = 4; page <= 7; page++) {
            final response = await nfcA.transceive(
              data: Uint8List.fromList([
                0x30, // READ command
                page,
              ]),
            );


            buffer.addAll(response.sublist(0, 4));
          }

          nfcReadText = utf8.decode(buffer).replaceAll('\u0000', '').trim();

          NfcManager.instance.stopSession();
          completer.complete(true);
        } catch (e) {
          NfcManager.instance.stopSession(errorMessage: e.toString());
          completer.complete(false);
        }
      },
    );

    final success = await completer.future;

    if (success) {
      final completer = Completer<bool>();
      String character = "";
      String nfcText = nfcReadText;
      String? errorMessage;

      Connection.instance.socket.add(jsonEncode({"message": "useNFC", "code": nfcText}));
      socketSub = Connection.instance.broadcast.listen((data) {
        String serverMessage = data.toString();
        print(serverMessage);
        final decodedServerMessage = jsonDecode(serverMessage);
        String message = decodedServerMessage['message'];
        if(message == "check"){
          character = decodedServerMessage["character"];
          if(CharacterManager.instance.characters[character]!.unlocked){
            setState(() {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: You already have $character"),
                  duration: Duration(seconds: 4),
                ),
              );
            });
            socketSub.cancel();
            completer.complete(false);
          } else{
            Connection.instance.socket.add(jsonEncode({"message": "checked", "code": nfcText, "character": character, "continue": "true"}));
          }
        }
        else if(message == "alreadyUsed"){
          errorMessage = "Tag already used";
          socketSub.cancel();
          completer.complete(false);
        }
        else if(message == "unlockCharacter"){
          character = decodedServerMessage["character"];
          socketSub.cancel();
          completer.complete(true);
        }
      });

      final unlockCharacter = await completer.future;
      if(unlockCharacter){
        print("Unlocking");
        await CharacterManager.instance.unlock(character);

        // if(!mounted) return;

        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$character unlocked!"),
              duration: Duration(seconds: 4),
            ),
          );
          print("Unlocked");
        });
      } else{
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $errorMessage"),
              duration: Duration(seconds: 4),
            ),
          );
        });
      }
    }
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
                    if(character.unlocked){
                      setState((){selectedCharacter = character;});
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: character.unlocked ? Colors.blueGrey.shade900 : Colors.black26,
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

          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.grey.shade900,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedCharacter.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Life Points: ${selectedCharacter.lifePoints}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Damage: ${selectedCharacter.damage}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: () async {await readNFC();},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text(
                      "Read NFC",
                      style: TextStyle(fontSize: 18)
                    ),
                  ),

                  SizedBox(height: 10,),

                  ElevatedButton(
                    onPressed: () async {await lockCharacters();},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text(
                        "Lock characters",
                        style: TextStyle(fontSize: 18)
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