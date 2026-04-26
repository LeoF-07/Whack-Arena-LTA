import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'characters/character.dart';
import 'characters/character_manager.dart';
import 'connection/connection.dart';
import 'homepage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.device.fullScreen(); // Senza await nell'emulator andrebbe bene comunque ma nell'apk no
  await Flame.device.setLandscape(); // Senza await nell'emulator andrebbe bene comunque ma nell'apk no

  runApp(const MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp>{
  late WebSocket socket;
  late Stream broadcast;
  late StreamSubscription socketSub;
  bool dataFetched = false;

  @override
  void initState() {
    _connect();
    super.initState();
  }

  void _connect() async {
    try {
      // 151.49.35.17:8176 indirizzo router
      socket = await WebSocket.connect('ws://151.95.238.133:8080/ws');
      broadcast = socket.asBroadcastStream();
      socketSub = broadcast.listen((data) {
        String serverMessage = data.toString();
        print(serverMessage);
        final decodedServerMessage = jsonDecode(serverMessage);
        String message = decodedServerMessage['message'];
        if(message == "characters"){
          print("Data fetched");
          final List<Character> characters = (decodedServerMessage['characters'] as List)
              .map((c) => Character.fromJson(c))
              .toList();
          CharacterManager.instance.load(characters);
          print(CharacterManager.instance.get("Knight"));

          setState(() {
            dataFetched = true;
          });
          socketSub.cancel();
        }
      });

      // Non serve salvare socketSub
      Connection.instance.init(socket: socket, broadcast: broadcast, streamSubscription: socketSub);
    } catch (e) {
      print("Errore");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 12/13/14
      minTextAdapt: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: dataFetched ? HomePage() : const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
          )
        );
      },
    );

    /*
    return MaterialApp(
      home: dataFetched ? HomePage() : const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
    */
  }
}
