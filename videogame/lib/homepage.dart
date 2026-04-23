import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:videogame/components/character_manager.dart';
import 'components/character_selection.dart';
import 'pvp_game.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {


  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;


  final List<String> backgrounds = [
    "assets/images/Home Page/bg1.jpg",
    "assets/images/Home Page/bg2.jpg",
    "assets/images/Home Page/bg3.jpg",
  ];


  int currentIndex = 0;
  Timer? bgTimer;


  @override
  void initState() {
    super.initState();


    /// 🌊 animazione respiro
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);


    _scaleAnim = Tween<double>(begin: 0.97, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );


    _opacityAnim = Tween<double>(begin: 0.75, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );


    /// 🔥 preload sfondi (fix flash bianco)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final bg in backgrounds) {
        precacheImage(AssetImage(bg), context);
      }
    });


    /// 🔄 rotazione sfondi
    bgTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        currentIndex = (currentIndex + 1) % backgrounds.length;
      });
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    bgTimer?.cancel();
    super.dispose();
  }


  /// 🎯 BOTTONI TONDI
  Widget buildButton(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            imagePath,
            width: 220,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [


          /// 🌄 BACKGROUND
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: AnimatedScale(
                duration: const Duration(seconds: 6),
                scale: 1.1,
                child: Image.asset(
                  backgrounds[currentIndex],
                  key: ValueKey(backgrounds[currentIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),


          /// 🎮 CONTENUTO
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                /// ⚡ TITOLO MAGICO POTENZIATO
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {


                    final glow = (_opacityAnim.value - 0.75) * 100;
                    final shake = (_scaleAnim.value - 1) * 2;


                    return Transform.translate(
                      offset: Offset(shake, 0),
                      child: Transform.scale(
                        scale: _scaleAnim.value,
                        child: Opacity(
                          opacity: _opacityAnim.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [


                              /// 🎮 WACK ARENA
                              Text(
                                "WACK ARENA",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                  fontFamily: "Arial Rounded MT Bold",
                                  shadows: [
                                    /// 💚 glow verde principale
                                    Shadow(
                                      blurRadius: 120 + glow,
                                      color: Colors.greenAccent.withAlpha((0.9 * 255).floor()),
                                      offset: const Offset(0, 0),
                                    ),


                                    /// 💚 glow verde secondario più soft
                                    Shadow(
                                      blurRadius: 80 + glow,
                                      color: Colors.lightGreenAccent.withAlpha((0.7 * 255).floor()),
                                      offset: const Offset(0, 0),
                                    ),


                                    /// ⚫ ombra di profondità (per non perdere leggibilità)
                                    Shadow(
                                      blurRadius: 35,
                                      color: Colors.black,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                              ),


                              const SizedBox(height: 4),


                              /// ⚡ LTA
                              Text(
                                "LTA",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                  letterSpacing: 10,
                                  shadows: [
                                    Shadow(
                                      blurRadius: glow,
                                      color: Colors.purpleAccent.withAlpha((0.5 * 255).floor()), // = alpha 0.5 (0.5 * 255)
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),


                const SizedBox(height: 80),


                /// 🎯 BOTTONI TONDI
                buildButton(
                    "assets/images/Home Page/play_button.png",
                    () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CharacterSelection()));
                    }
                ),
                const SizedBox(height: 20),
                buildButton(
                    "assets/images/Home Page/test_button.png",
                      () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => GameWidget(
                        game: PVPGame(mode: "debug", character: CharacterManager.instance.characters["Knight"]!, room: "debug"),
                        autofocus: true,
                      )));
                    }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}