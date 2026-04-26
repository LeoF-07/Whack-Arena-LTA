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

  String nfcReadValue = "";

  @override
  void initState() {
    characters = CharacterManager.instance.characters.values.toList();
    super.initState();
  }

  Future<void> readNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) return;

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final nfcA = NfcA.from(tag);
          if (nfcA == null) {
            NfcManager.instance.stopSession(errorMessage: "Tag non supportato");
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

          final text = utf8.decode(buffer).trim();

          setState(() {
            nfcReadValue = text;
          });

          NfcManager.instance.stopSession();
        } catch (e) {
          NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
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
                    if(character.unlocked){
                      setState((){selectedCharacter = character;});
                    }
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
                    onPressed: readNFC,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text(
                      "Read NFC",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🔵 JOIN ROOM
                  Text(
                    "Valore letto: $nfcReadValue",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
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