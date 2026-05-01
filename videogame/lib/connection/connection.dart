import 'dart:async';
import 'dart:io';

class Connection{
  static final Connection instance = Connection._internal();
  Connection._internal();

  late final WebSocket socket;
  late final Stream broadcast;

  void init({required WebSocket socket, required Stream broadcast}) {
    this.socket = socket;
    this.broadcast = broadcast;
  }
}