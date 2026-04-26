class NetSnapshot {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final int timestamp; // in ms
  final String state;

  NetSnapshot({required this.x, required this.y, required this.vx, required this.vy, required this.timestamp, required this.state});
}