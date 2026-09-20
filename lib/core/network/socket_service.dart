import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

abstract class SocketService {
  /// Connects to a Socket.io server. Enforces secure protocols in production.
  void connect(String url, {String? token});

  /// Emits a 'send_message' event with the message payload.
  void sendMessage(Map<String, dynamic> data);

  /// Disconnects from the Socket.io server and closes all stream controllers.
  void disconnect();

  /// Stream of incoming 'message' events.
  Stream<dynamic> get onMessage;

  /// Stream of incoming 'typing' events.
  Stream<dynamic> get onTyping;

  /// Stream of incoming 'seen' events.
  Stream<dynamic> get onSeen;

  /// Stream of incoming 'online' events indicating user online status changes.
  Stream<dynamic> get onOnline;

  /// Stream indicating whether the socket is currently connected.
  Stream<bool> get onConnectionState;
}

@LazySingleton(as: SocketService)
class SocketServiceImpl implements SocketService {
  socket_io.Socket? _socket;

  // Stream controllers to broadcast real-time events to multiple UI listeners
  final StreamController<dynamic> _messageController = StreamController<dynamic>.broadcast();
  final StreamController<dynamic> _typingController = StreamController<dynamic>.broadcast();
  final StreamController<dynamic> _seenController = StreamController<dynamic>.broadcast();
  final StreamController<dynamic> _onlineController = StreamController<dynamic>.broadcast();
  final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();

  @override
  Stream<dynamic> get onMessage => _messageController.stream;

  @override
  Stream<dynamic> get onTyping => _typingController.stream;

  @override
  Stream<dynamic> get onSeen => _seenController.stream;

  @override
  Stream<dynamic> get onOnline => _onlineController.stream;

  @override
  Stream<bool> get onConnectionState => _connectionStateController.stream;

  @override
  void connect(String url, {String? token}) {
    // If socket is already active, close the existing one first
    if (_socket != null) {
      disconnect();
    }

    var connectionUrl = url;
    // Enforce secure https/wss protocols in production environments
    if (!kDebugMode) {
      if (url.startsWith('http://')) {
        connectionUrl = url.replaceFirst('http://', 'https://');
      } else if (url.startsWith('ws://')) {
        connectionUrl = url.replaceFirst('ws://', 'wss://');
      } else if (!url.startsWith('https://') && !url.startsWith('wss://')) {
        connectionUrl = 'https://$url';
      }
    }

    debugPrint('[SocketService] Initializing connection to: $connectionUrl');

    // Build the Socket.io client configuration options
    final options = socket_io.OptionBuilder()
        .setTransports(['websocket']) // Force websocket transport for absolute stability
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionDelay(5000) // Retry connection every 5 seconds on drop
        .setReconnectionAttempts(20) // Allow up to 20 reconnection attempts
        .setExtraHeaders({
          if (token != null) 'Authorization': 'Bearer $token',
        })
        .build();

    _socket = socket_io.io(connectionUrl, options);

    _setupListeners();
  }

  void _setupListeners() {
    final socket = _socket;
    if (socket == null) return;

    // Connection lifecycle events
    socket.onConnect((_) {
      debugPrint('[SocketService] Connected successfully.');
      _connectionStateController.add(true);
    });

    socket.onDisconnect((_) {
      debugPrint('[SocketService] Disconnected.');
      _connectionStateController.add(false);
    });

    socket.onConnectError((err) {
      debugPrint('[SocketService] Connection error: $err');
      _connectionStateController.add(false);
    });

    // Native Heartbeat Monitor logging
    socket.on('ping', (_) {
      debugPrint('[SocketService] Heartbeat ping sent.');
    });

    socket.on('pong', (latency) {
      debugPrint('[SocketService] Heartbeat pong received. Latency: $latency ms.');
    });

    // Custom real-time business events requested by UI
    socket.on('message', (data) {
      debugPrint('[SocketService] Received event "message": $data');
      _messageController.add(data);
    });

    socket.on('typing', (data) {
      debugPrint('[SocketService] Received event "typing": $data');
      _typingController.add(data);
    });

    socket.on('seen', (data) {
      debugPrint('[SocketService] Received event "seen": $data');
      _seenController.add(data);
    });

    socket.on('online', (data) {
      debugPrint('[SocketService] Received event "online": $data');
      _onlineController.add(data);
    });
  }

  @override
  void sendMessage(Map<String, dynamic> data) {
    final socket = _socket;
    if (socket != null && socket.connected) {
      debugPrint('[SocketService] Emitting "send_message" event: $data');
      socket.emit('send_message', data);
    } else {
      debugPrint('[SocketService] Cannot emit message; socket is disconnected.');
    }
  }

  @override
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionStateController.add(false);
    debugPrint('[SocketService] Socket disposed and cleaned up.');
  }
}
