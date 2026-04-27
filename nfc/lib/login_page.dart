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
  String labelText = "Password";
  bool incorrectPassword = false;
  final TextEditingController passwordController = TextEditingController();

  Future<void> connect() async {
    try{
      DatabaseService db = DatabaseService();
      await db.connect(password);

      if(!mounted){
        return;
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) => NFCPage(db: db)));
    } catch(e){

      if(e.toString().contains("Access denied") || e.toString().contains("1045")){
        setState(() {
          incorrectPassword = true;
          passwordController.clear();
          password = "";
          labelText = "Incorrect Password";
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Incorrect Password"),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
      } else{
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connessione fallita: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
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
                controller: passwordController,
                onChanged: (v) => password = v,
                obscureText: true,
                obscuringCharacter: '*',
                enableSuggestions: false,
                autocorrect: false,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: labelText,
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: incorrectPassword ? Colors.redAccent : Colors.greenAccent),
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