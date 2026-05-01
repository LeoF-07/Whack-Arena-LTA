import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'dart:math';
import 'game_session.dart';
import 'database_service.dart';
import 'character_manager.dart';

List<Map<String, dynamic>> connections = [];
List<String> rooms = [];
int index = 0;

String hashCodeString(String code) {
    final bytes = utf8.encode(code);
    return sha256.convert(bytes).toString();
  }

String _generateRoomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rand = Random();
  return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
}

String _createUniqueRoom() {
  String code;
  do {
    code = _generateRoomCode();
  } while (rooms.contains(code));
  return code;
}

Future<void> main() async {
  final pwd = Platform.environment['SERVER_PASSWORD'];

  if(pwd == null || pwd.isEmpty){
    stderr.write("ERRORE: variabile d'ambiente SERVER_PASSWORD non impostata.");
    exit(1);
  }

  DatabaseService db = DatabaseService();
  await db.connect(pwd);

  final characters = await db.getCharacterForServer();
  CharacterManager.instance.load(characters);
  final clientCharacters = await db.getCharacterForClient();

  final HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Server avviato su ws://localhost:8080/ws');

  await for (HttpRequest req in server) {
    print('Richiesta ricevuta: ${req.uri.path} da ${req.connectionInfo?.remoteAddress}');
    if (req.uri.path == '/ws'){
      print("Tentativo di upgrade...");
      WebSocket socket = await WebSocketTransformer.upgrade(req);
      print('Nuovo client collegato');

      print("Fetching data");
      socket.add(jsonEncode({"message": "characters", "characters": clientCharacters}));

      index++;
      int id = index;

      Stream broadcast = socket.asBroadcastStream();
      StreamSubscription socketSub = broadcast.listen((data) async {
        final decodedMessage = jsonDecode(data);
        if(decodedMessage["message"] == "createRoom"){
          String roomCode = _createUniqueRoom();
          socket.add(jsonEncode({"message": "room", "room": roomCode}));
        }
        if(decodedMessage['message'] == "wantToPlay"){
          String room = decodedMessage["room"];
          _addOrJoinRoom(room, id);
        }
        if(decodedMessage["message"] == "useNFC"){
          bool used = await db.codeUsed(hashCodeString(decodedMessage["code"]));

          if(used){
            socket.add(jsonEncode({"message": "alreadyUsed", "code": decodedMessage["code"]}));
          }else{
            String characterName = await db.findCharacter(hashCodeString(decodedMessage["code"]));
            socket.add(jsonEncode({"message": "check", "character": characterName}));
          }
        }
        if(decodedMessage["message"] == "checked" && decodedMessage["continue"] == "true"){
          bool success = await db.useNFC(hashCodeString(decodedMessage["code"]));
          if(success){
            socket.add(jsonEncode({"message": "unlockCharacter", "character": decodedMessage["character"]}));
          }
        }
      },
      onDone: () {
        print("Il client ha chiuso la connessione");
        _removeConnection(id);
      },
      onError: (err) {
        print("Il client ha chiuso la connessione");
        _removeConnection(id);
      });

      Map<String, dynamic> connection = {
        "id": id,
        "socket": socket,
        "broadcast": broadcast,
        "streamSubscription": socketSub,
        "room": ""
      };
      connections.add(connection);
    } 
    else {
      req.response
        ..statusCode = HttpStatus.notFound
        ..write('Endpoint non valido')
        ..close();
    }
  }
}

void _removeConnection(int id) {
  final index = connections.indexWhere((c) => c["id"] == id);
  if (index != -1) {
    final conn = connections.removeAt(index);
    final StreamSubscription sub = conn["streamSubscription"];
    sub.cancel();
    print("Connessione rimossa dalla lista");
  }
}

void _addOrJoinRoom(String room, int id){
  final index = connections.indexWhere((c) => c["room"] == room);
  int myIndex = connections.indexWhere((c) => c["id"] == id);

  if (index != -1) {
    int opponentIndex = index;
    Map<String, dynamic> opponentConn;
    Map<String, dynamic> myConn;

    if(myIndex > opponentIndex){
      myConn = connections.removeAt(myIndex);
      opponentConn = connections.removeAt(opponentIndex);
    } else{
      opponentConn = connections.removeAt(opponentIndex);
      myConn = connections.removeAt(myIndex);
    }
    WebSocket s1 = myConn["socket"];
    WebSocket s2 = opponentConn["socket"];
    Stream b1 = myConn["broadcast"];
    Stream b2 = opponentConn["broadcast"];
    StreamSubscription ss1 = myConn["streamSubscription"];
    StreamSubscription ss2 = opponentConn["streamSubscription"];
    ss1.cancel();
    ss2.cancel();
    GameSession(socket1: s1, socket2: s2, broadcast1: b1, broadcast2: b2);
  } else {
    connections[myIndex]["room"] = room;
  }
}