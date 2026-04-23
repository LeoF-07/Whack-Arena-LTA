import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class AnimatedDotsText extends TextComponent {
  double _timer = 0;
  int _state = 0;
  final String originalText;

  AnimatedDotsText({required Vector2 position, double fontSize = 24, required this.originalText}) : super(
    text: originalText,
    anchor: Anchor.center,
    position: position,
    priority: 300,
    textRenderer: TextPaint(
      style: TextStyle(
        color: const Color(0xFFFFFFFF),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(
            blurRadius: 4,
            color: Color(0xFF000000),
            offset: Offset(2, 2),
          ),
        ],
      ),
    ),
  );

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer >= 0.5) {
      _timer = 0;
      _state = (_state + 1) % 3;

      switch (_state) {
        case 0:
          text = "$originalText.";
          break;
        case 1:
          text = "$originalText..";
          break;
        case 2:
          text = "$originalText...";
          break;
      }
    }
  }
}