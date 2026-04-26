import 'package:flutter/material.dart';
import 'package:nfc/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}




/*
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NFCTestPage(),
    );
  }
}

class NFCTestPage extends StatefulWidget {
  const NFCTestPage({super.key});

  @override
  State<NFCTestPage> createState() => _NFCTestPageState();
}

class _NFCTestPageState extends State<NFCTestPage> {
  String selectedCharacter = "Knight";
  String password = "";
  String nfcReadValue = "";

  Future<void> writeToNfc() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) return;

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          NfcManager.instance.stopSession(errorMessage: "Tag non scrivibile");
          return;
        }

        final message = NdefMessage([
          NdefRecord.createText(selectedCharacter),
        ]);

        try {
          await ndef.write(message);
          NfcManager.instance.stopSession();
        } catch (e) {
          NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
    );
  }

  Future<void> readFromNfc() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) return;

    print("Ciao1");

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        print("Ciao2");
        final ndef = Ndef.from(tag);
        if (ndef == null) {
          NfcManager.instance.stopSession(errorMessage: "Tag non NDEF");
          return;
        }

        final cached = ndef.cachedMessage;
        if (cached != null && cached.records.isNotEmpty) {
          final record = cached.records.first;
          final text = String.fromCharCodes(record.payload).substring(3);

          setState(() {
            nfcReadValue = text;
          });
        }

        NfcManager.instance.stopSession();
      },
    );
  }

  Widget buildCharacterButton(String name) {
    final bool selected = selectedCharacter == name;

    return GestureDetector(
      onTap: () => setState(() => selectedCharacter = name),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.green : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              buildCharacterButton("Knight"),
              buildCharacterButton("Dwarf"),

              const SizedBox(height: 30),

              TextField(
                onChanged: (v) => password = v,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: writeToNfc,
                child: const Text("Scrivi su NFC"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: readFromNfc,
                child: const Text("Leggi da NFC"),
              ),

              const SizedBox(height: 30),

              Text(
                "Valore letto: $nfcReadValue",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/