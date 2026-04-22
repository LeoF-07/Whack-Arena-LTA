import 'dart:async';
import 'dart:io';

class Connection{
  static final Connection instance = Connection._internal();
  Connection._internal();

  late final WebSocket socket;
  late final Stream broadcast;
  late final StreamSubscription streamSubscription;

  void init({required WebSocket socket, required Stream broadcast, required StreamSubscription streamSubscription}) {
    this.socket = socket;
    this.broadcast = broadcast;
    this.streamSubscription = streamSubscription;
  }
}