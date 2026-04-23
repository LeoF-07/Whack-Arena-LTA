import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:videogame/pvp_game.dart';

class HealthBar extends PositionComponent with HasGameReference<PVPGame> {
  int maxHealth;
  int currentHealth;
  final bool opponent;
  final double barWidth;
  final double barHeight;

  late SvgComponent _svgComponent;

  HealthBar({
    required this.maxHealth,
    required this.currentHealth,
    this.opponent = false,
    this.barWidth = 150,
    this.barHeight = 30,
  }) : super(priority: 100);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadSvg();
  }

  Future<void> _loadSvg() async {
    final svgString = _generateSvg();

    final svg = await Svg.loadFromString(svgString);

    _svgComponent = SvgComponent(
      svg: svg,
      size: Vector2(250, 70),
    )..scale = Vector2.all(0.7);

    // Posizionamento come nel tuo codice
    final double offsetX = opponent ? game.size.x - 220 : 46;
    position = Vector2(offsetX, 15);

    add(_svgComponent);
  }

  /// Aggiorna la vita e rigenera l'SVG
  void applyDamage(int damage) async {
    currentHealth -= damage;
    if (currentHealth < 0) currentHealth = 0;

    final svgString = _generateSvg();
    final svg = await Svg.loadFromString(svgString);
    _svgComponent.svg = svg;
  }

  /// Genera l'SVG con la barra interna ridimensionata
  String _generateSvg() {
    final hpPercent = currentHealth / maxHealth;
    final hpWidth = 200 * hpPercent; // 200px = larghezza barra originale

    return '''
      <svg width="250" height="70" viewBox="0 0 250 70" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <linearGradient id="healthGradient" x1="${opponent ? 100 : 0}%" y1="0%" x2="${opponent ? 0 : 100}%" y2="0%">
            <stop offset="0%" stop-color="#8B0000" />
            <stop offset="50%" stop-color="#FF0000" />
            <stop offset="100%" stop-color="#FF4500" />
          </linearGradient>
      
          <linearGradient id="gloss" x1="0%" y1="${opponent ? 100 : 0}%" x2="0%" y2="${opponent ? 0 : 100}%">
            <stop offset="0%" stop-color="white" stop-opacity="0.4" />
            <stop offset="100%" stop-color="black" stop-opacity="0.2" />
          </linearGradient>
        </defs>
      
        <path d="M15 20 L5 35 L15 50 L235 50 L245 35 L235 20 Z"
              fill="#222" stroke="#C0C0C0" stroke-width="2" />
      
        <path d="M20 25 L10 35 L20 45 L230 45 L240 35 L230 25 Z"
              fill="none" stroke="#FFD700" stroke-width="1.5" />
      
        <rect x="25" y="30" width="200" height="10" rx="2" fill="#111" />
      
        <rect x="${opponent ? 25 + (200 - hpWidth) : 25}" y="30" width="$hpWidth" height="10" rx="2" fill="url(#healthGradient)">
          <animate attributeName="fill-opacity" values="1;0.8;1" dur="1.2s" repeatCount="indefinite" />
        </rect>
      
        <rect x="${opponent ? 25 + (200 - hpWidth) : 25}" y="30" width="$hpWidth" height="5" rx="2" fill="url(#gloss)" />
      
        ${
          opponent ?
          '''
            <path d="M225 35 L230 30 L235 35 L230 40 Z"
              fill="#FF0000" stroke="#FFD700" stroke-width="1">
              <animate attributeName="stroke-width" values="1;2;1" dur="1s" repeatCount="indefinite" />
            </path>
          ''' :
          '''
            <path d="M15 35 L20 30 L25 35 L20 40 Z"
                  fill="#FF0000" stroke="#FFD700" stroke-width="1">
              <animate attributeName="stroke-width" values="1;2;1" dur="1s" repeatCount="indefinite" />
            </path>
          '''
        }
        
        ${
          opponent ?
          '''
              <circle cx="20" cy="35" r="3" fill="#FFD700" />
          ''' :
          '''
              <circle cx="230" cy="35" r="3" fill="#FFD700" />
          '''
        }
      </svg>
    ''';
  }
}