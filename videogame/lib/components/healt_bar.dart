import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:videogame/pvp_game.dart';

class HealthBar extends PositionComponent with HasGameReference<PVPGame> {
  int maxHealth;
  int currentHealth;
  final bool opponent;
  final double barWidth;
  final double barHeight;

  HealthBar({
    required this.maxHealth,
    required this.currentHealth,
    this.opponent = false,
    this.barWidth = 150,
    this.barHeight = 30,
  }) : super(priority: 100);

  @override
  void render(Canvas canvas) {
    double offsetX;
    if(opponent){
      offsetX = game.size.x - 200;
    }else{
      offsetX = 32;
    }
    // Sfondo barra (vuota)
    final bgPaint = Paint()..color = Colors.red.shade900;
    canvas.drawRect(
      // Rect.fromLTWH(32, 20, barWidth, barHeight),
      Rect.fromLTWH(offsetX, 20, barWidth, barHeight),
      bgPaint,
    );

    // Percentuale vita
    double hpPercent = currentHealth / maxHealth;
    double hpWidth = barWidth * hpPercent;

    // Barra vita (piena)
    final fgPaint = Paint()..color = Colors.greenAccent;
    canvas.drawRect(
      Rect.fromLTWH(offsetX, 20, hpWidth, barHeight),
      fgPaint,
    );
  }

  void applyDamage(int damage) {
    currentHealth -= damage;
    if (currentHealth < 0) currentHealth = 0;
  }
}