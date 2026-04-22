import 'character.dart';

class CharacterManager { // Singleton
  static final CharacterManager instance = CharacterManager._internal();

  CharacterManager._internal();

  final Map<String, Character> characters = {};

  void load(List<Character> list) {
    characters.clear();
    for (var c in list) {
      characters[c.name] = c;
    }
  }

  Character get(String name) => characters[name]!;
}
