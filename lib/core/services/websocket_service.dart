import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';

import 'settings_service.dart';
import '../../features/montage/domain/models/montage_profile_model.dart';

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
  StreamController<AlarmStatusUpdate>? _alarmStatusController;
  StreamController<EventCountUpdate>? _eventCountController;
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

  /// Stream for alarm status updates
  Stream<AlarmStatusUpdate> get alarmStatusStream {
    _alarmStatusController ??= StreamController<AlarmStatusUpdate>.broadcast();
    return _alarmStatusController!.stream;
  }

  /// Stream for event count updates
  Stream<EventCountUpdate> get eventCountStream {
    _eventCountController ??= StreamController<EventCountUpdate>.broadcast();
    return _eventCountController!.stream;
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
      final type = data['type'] as String?;
      
      switch (type) {
        case 'alarm':
          _handleAlarmEvent(data);
          break;
        case 'event':
          _handleNewEvent(data);
          _eventController?.add(data);
          break;
        case 'monitor_status':
          _handleMonitorStatus(data);
          break;
        default:
          _eventController?.add(data);
      }
      
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void _handleAlarmEvent(Map<String, dynamic> data) {
    final monitorId = data['monitor_id'] as String?;
    final alarmState = data['alarm_state'] as String?;
    
    if (monitorId != null && alarmState != null) {
      _alarmStatusController?.add(AlarmStatusUpdate(
        cameraId: monitorId,
        status: _parseAlarmStatus(alarmState),
        timestamp: DateTime.now(),
      ));
    }
  }

  void _handleNewEvent(Map<String, dynamic> data) {
    final eventId = data['event_id'] as String?;
    final monitorId = data['monitor_id'] as String?;
    
    if (eventId != null && monitorId != null) {
      _eventCountController?.add(EventCountUpdate(
        cameraId: monitorId,
        newEventId: eventId,
        timestamp: DateTime.now(),
      ));
    }
  }

  void _handleMonitorStatus(Map<String, dynamic> data) {
    final monitorId = data['monitor_id'] as String?;
    final status = data['status'] as String?;
    
    if (monitorId != null && status != null) {
      _alarmStatusController?.add(AlarmStatusUpdate(
        cameraId: monitorId,
        status: _parseAlarmStatus(status),
        timestamp: DateTime.now(),
      ));
    }
  }

  AlarmStatus _parseAlarmStatus(String status) {
    switch (status.toLowerCase()) {
      case 'alarm':
      case 'alarmed':
        return AlarmStatus.alarmed;
      case 'alert':
        return AlarmStatus.alert;
      case 'recording':
        return AlarmStatus.recording;
      default:
        return AlarmStatus.idle;
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
    _alarmStatusController?.close();
    _eventCountController?.close();
    _reconnectTimer?.cancel();
  }
}
