import 'character.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterManager { // Singleton
  static final CharacterManager instance = CharacterManager._internal();

  CharacterManager._internal();

  final Map<String, Character> characters = {};
  final List<String> unlocked = [];

  Future<void> load(List<Character> list) async {
    characters.clear();
    await loadUnlocked();

    if(unlocked.isEmpty){
      unlocked.add("Knight");
      saveUnlocked();
    }

    for (var c in list) {
      if(unlocked.contains(c.name)){
        c.unlocked = true;
      }
      characters[c.name] = c;
    }
  }

  Future<void> unlock(String name) async {
    unlocked.add(name);
    characters[unlocked.last]!.unlocked = true;
    await saveUnlocked();
  }

  Future<void> loadUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("unlocked_characters") ?? [];
    unlocked
      ..clear()
      ..addAll(list);
  }

  Future<void> saveUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("unlocked_characters", unlocked.toList());
  }

  Future<void> lockCharacters() async {
    unlocked.clear();
    unlocked.add("Knight");
    for(Character character in characters.values){
      character.unlocked = false;
    }
    characters["Knight"]!.unlocked = true;
    saveUnlocked();
  }


  Character get(String name) => characters[name]!;
}