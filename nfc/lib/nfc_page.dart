import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'database_service.dart';

class NFCPage extends StatefulWidget {
  final DatabaseService db;
  const NFCPage({super.key, required this.db});

  @override
  State<NFCPage> createState() => _NFCPageState();
}

class _NFCPageState extends State<NFCPage> {
  String selectedCharacter = "Knight";
  String nfcReadValue = "";
  bool dataFetched = false;

  late Map<String, int> characters;

  @override
  initState() {
    super.initState();

    widget.db.getCharacterMap().then((res) {
      characters = res;
      setState(() {
        dataFetched = true;
      });
    });
  }

  String generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  // -------------------------------------------------------
  // SCRITTURA RAW (NTAG21x / Ultralight)
  // -------------------------------------------------------
  Future<void> writeRaw() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) return;

    String character = selectedCharacter;
    int characterID = characters[character]!;
    String randomCode = generateRandomCode(10);

    bool duplicated = await widget.db.searchDuplicated(randomCode);
    if(duplicated){
      print("Duplicato");
      return;
    }

    final completer = Completer<bool>();

    final data = utf8.encode(randomCode);

    // Pad a multipli di 4 byte
    List<int> padded = List.from(data);
    while (padded.length % 4 != 0) {
      padded.add(0x00);
    }

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final nfcA = NfcA.from(tag);
          if (nfcA == null) {
            NfcManager.instance.stopSession(errorMessage: "Tag non supportato");
            completer.complete(false);
            return;
          }

          // 1️⃣ CANCELLAZIONE COMPLETA (pagine 4–15)
          for (int page = 4; page <= 15; page++) {
            await nfcA.transceive(
              data: Uint8List.fromList([
                0xA2, page,
                0x00, 0x00, 0x00, 0x00,
              ]),
            );
          }

          // 2️⃣ SCRITTURA DEL NUOVO MESSAGGIO
          int page = 4;
          for (int i = 0; i < padded.length; i += 4) {
            await nfcA.transceive(
              data: Uint8List.fromList([
                0xA2, page,
                padded[i],
                padded[i + 1],
                padded[i + 2],
                padded[i + 3],
              ]),
            );
            page++;
          }

          // await widget.db.addCode(characterID, randomCode);
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
      await widget.db.addCode(characterID, randomCode);

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tag creato: $character, $randomCode"),
            duration: Duration(seconds: 4),
          ),
        );
      });
    } else {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Errore durante la scrittura del tag."),
            duration: Duration(seconds: 4),
          ),
        );
      });
    }
  }



  // -------------------------------------------------------
  // LETTURA RAW (NTAG21x / Ultralight)
  // -------------------------------------------------------
  Future<void> readRaw() async {
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

  Future<void> unlockAllTags() async {
    widget.db.unlockAllTags();
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tag sbloccati"),
          duration: Duration(seconds: 4),
        ),
      );
    });
  }

  // -------------------------------------------------------
  // UI
  // -------------------------------------------------------
  Widget buildCharacterButtons() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, // numero di colonne
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5, // regola forma dei pulsanti
      children: characters.entries.map((entry) {
        final name = entry.key;
        final bool selected = selectedCharacter == name;

        return GestureDetector(
          onTap: () => setState(() => selectedCharacter = name),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? Colors.green : Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return !dataFetched ? const Scaffold(
        body: Center(
            child: CircularProgressIndicator()
        )
    ) :
    Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Seleziona personaggio",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),

              const SizedBox(height: 12),

              buildCharacterButtons(),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: writeRaw,
                child: const Text("Scrivi RAW su NFC"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: readRaw,
                child: const Text("Leggi RAW da NFC"),
              ),

              const SizedBox(height: 30),

              Text(
                "Valore letto: $nfcReadValue",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {await unlockAllTags();},
                child: const Text("Sblocca tutti i tag"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}