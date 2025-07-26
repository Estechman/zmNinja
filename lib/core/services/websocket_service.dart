import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';

import 'settings_service.dart';

/// WebSocket service provider for real-time ZoneMinder updates
final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return WebSocketService(settingsService);
});

/// Provider for WebSocket connection status
final websocketConnectionProvider = StreamProvider<bool>((ref) {
  final websocketService = ref.watch(websocketServiceProvider);
  return websocketService.connectionStatusStream;
});

/// Provider for real-time event notifications
final realtimeEventsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final websocketService = ref.watch(websocketServiceProvider);
  return websocketService.eventStream;
});

/// Service for managing WebSocket connections to ZoneMinder
/// Handles real-time event notifications and status updates
class WebSocketService {
  final SettingsService _settingsService;
  WebSocketChannel? _channel;
  StreamController<bool>? _connectionController;
  StreamController<Map<String, dynamic>>? _eventController;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  
  WebSocketService(this._settingsService);

  /// Stream for connection status updates
  Stream<bool> get connectionStatusStream {
    _connectionController ??= StreamController<bool>.broadcast();
    return _connectionController!.stream;
  }

  /// Stream for real-time event notifications
  Stream<Map<String, dynamic>> get eventStream {
    _eventController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _eventController!.stream;
  }

  /// Connect to ZoneMinder WebSocket endpoint
  Future<void> connect() async {
    if (_isConnecting || _channel != null) return;
    
    _isConnecting = true;
    
    try {
      final settings = await _settingsService.getAppSettings();
      final serverSettings = settings.serverSettings;
      
      if (!serverSettings.isConfigured) {
        _connectionController?.add(false);
        return;
      }
      
      // Build WebSocket URL
      final protocol = serverSettings.useHttps ? 'wss' : 'ws';
      final port = serverSettings.port;
      final portSuffix = (serverSettings.useHttps && port == 443) || 
                        (!serverSettings.useHttps && port == 80) ? '' : ':$port';
      
      final wsUrl = '$protocol://${serverSettings.serverUrl}$portSuffix/zm/cgi-bin/zms';
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Listen for messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      _connectionController?.add(true);
      _isConnecting = false;
      
    } catch (e) {
      _handleError(e);
      _isConnecting = false;
    }
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _connectionController?.add(false);
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message.toString()) as Map<String, dynamic>;
      
      // Process different message types
      if (data['type'] == 'event') {
        _eventController?.add(data);
      } else if (data['type'] == 'alarm') {
        _eventController?.add(data);
      }
      
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _connectionController?.add(false);
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    print('WebSocket disconnected');
    _channel = null;
    _connectionController?.add(false);
    _scheduleReconnect();
  }

  /// Schedule automatic reconnection
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_channel == null) {
        connect();
      }
    });
  }

  /// Send message to WebSocket
  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _connectionController?.close();
    _eventController?.close();
    _reconnectTimer?.cancel();
  }
}
