import 'package:flutter/material.dart';
import 'package:nfc/nfc_page.dart';

import 'database_service.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>{
  String password = "";

  Future<void> connect() async {
    DatabaseService db = DatabaseService();
    await db.connect(password);

    if(!mounted){
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => NFCPage(db: db)));
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

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: connect,
                child: const Text("Connect"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}