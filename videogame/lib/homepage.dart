import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:videogame/components/character_manager.dart';
import 'components/character_selection.dart';
import 'pvp_game.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Gioco PvP",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CharacterSelection(),
                      ),
                      /*
                      MaterialPageRoute(
                        builder: (_) => GameWidget(
                          game: PVPGame(),
                          autofocus: true,
                        ),
                      ),
                      */
                    );
                  },
                  child: const Text(
                    "Gioca",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameWidget(
                          game: PVPGame(mode: "debug", character: CharacterManager.instance.characters["Knight"]!, room: "debug"),
                          autofocus: true,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Test",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
