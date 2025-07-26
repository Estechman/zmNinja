import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../features/home/domain/models/camera_model.dart';
import '../../features/events/domain/models/event_model.dart';
import '../../features/events/presentation/providers/events_providers.dart';
import '../../features/ptz/domain/models/ptz_capabilities_model.dart';
import '../../features/ptz/domain/models/ptz_preset_model.dart';
import '../../features/ptz/presentation/providers/ptz_providers.dart';
import 'settings_service.dart';

/// Provider for ZoneMinder API service
/// Manages all communication with ZoneMinder server
final zmApiServiceProvider = Provider<ZmApiService>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return ZmApiService(settingsService);
});

/// Service class for ZoneMinder API communication
/// Handles all HTTP requests to ZoneMinder server
class ZmApiService {
  late final Dio _dio;
  final SettingsService _settingsService;
  String? _baseUrl;
  String? _authToken;
  String? _authHash;

  ZmApiService(this._settingsService) {
    _dio = Dio();
    _setupInterceptors();
    _initializeFromSettings();
  }

  /// Initialize API service from stored settings
  Future<void> _initializeFromSettings() async {
    try {
      final settings = await _settingsService.getAppSettings();
      final serverSettings = settings.serverSettings;
      if (serverSettings.isConfigured) {
        configure(
          baseUrl: serverSettings.serverUrl!,
          username: serverSettings.username,
          password: serverSettings.password,
          useHttps: serverSettings.useHttps,
          apiPath: serverSettings.apiPath ?? '/zm/api',
        );
      }
    } catch (e) {
      // Settings not available yet, continue without configuration
    }
  }

  /// Setup Dio interceptors for authentication and logging
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add ZoneMinder authentication parameters
          if (_authToken != null && _authHash != null) {
            options.queryParameters.addAll({
              'token': _authToken,
              'auth': _authHash,
            });
          }
          
          // Set proper headers for ZoneMinder API
          options.headers.addAll({
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          });
          
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle authentication failures and retry logic
          if (error.response?.statusCode == 401) {
            // Token expired, attempt to re-authenticate
            _handleAuthenticationError();
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Handle authentication errors by clearing tokens
  void _handleAuthenticationError() {
    _authToken = null;
    _authHash = null;
    // TODO: Trigger re-authentication flow
  }

  /// Configure API service with server settings
  void configure({
    required String baseUrl,
    String? authToken,
    String? username,
    String? password,
    bool useHttps = true,
    String apiPath = '/zm/api',
  }) {
    // Build complete base URL with protocol and API path
    final protocol = useHttps ? 'https' : 'http';
    _baseUrl = '$protocol://$baseUrl$apiPath';
    _dio.options.baseUrl = _baseUrl!;
    
    // Set authentication if credentials provided
    if (username != null && password != null) {
      _authenticateWithCredentials(username, password);
    } else if (authToken != null) {
      _authToken = authToken;
    }
    
    // Configure timeouts for ZoneMinder
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
  }

  /// Authenticate with ZoneMinder using username/password
  Future<void> _authenticateWithCredentials(String username, String password) async {
    try {
      final response = await _dio.post('/host/login.json', data: {
        'user': username,
        'pass': password,
      });
      
      if (response.data['success'] == true) {
        _authToken = response.data['access_token'];
        _authHash = response.data['auth_hash'];
      } else {
        throw Exception('Authentication failed: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to authenticate with ZoneMinder: $e');
    }
  }

  /// Test connection to ZoneMinder server
  Future<bool> testConnection() async {
    // Return false immediately if no base URL is configured
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      return false;
    }
    
    try {
      final response = await _dio.get('/host/getVersion.json');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Get ZoneMinder server version and info
  Future<Map<String, dynamic>> getServerInfo() async {
    try {
      final response = await _dio.get('/host/getVersion.json');
      if (response.data['success'] == true) {
        return {
          'version': response.data['version'],
          'apiVersion': response.data['apiVersion'],
          'build': response.data['build'],
        };
      }
      throw Exception('Failed to get server info');
    } catch (e) {
      throw Exception('Failed to get server info: $e');
    }
  }

  /// Get list of cameras/monitors from ZoneMinder
  Future<List<CameraModel>> getCameras() async {
    try {
      final response = await _dio.get('/monitors.json');
      
      if (response.data['success'] != true) {
        throw Exception('API returned error: ${response.data['message']}');
      }
      
      final List<dynamic> monitorsData = response.data['monitors'] ?? [];
      
      return monitorsData.map((monitorData) {
        final monitor = monitorData['Monitor'] ?? monitorData;
        return CameraModel(
          id: monitor['Id'].toString(),
          name: monitor['Name'] ?? 'Unknown Camera',
          streamUrl: _buildStreamUrl(monitor['Id'].toString()),
          isOnline: monitor['Enabled'] == '1',
          isRecording: monitor['Function'] != 'None' && monitor['Function'] != 'Monitor',
          width: int.tryParse(monitor['Width']?.toString() ?? '0') ?? 1920,
          height: int.tryParse(monitor['Height']?.toString() ?? '0') ?? 1080,
          hasPtz: monitor['Controllable'] == '1',
          function: _parseCameraFunction(monitor['Function']),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch cameras: $e');
    }
  }

  /// Parse camera function from ZoneMinder
  CameraFunction _parseCameraFunction(String? function) {
    switch (function?.toLowerCase()) {
      case 'modect':
        return CameraFunction.modect;
      case 'record':
        return CameraFunction.record;
      case 'mocord':
        return CameraFunction.mocord;
      case 'nodect':
        return CameraFunction.nodect;
      default:
        return CameraFunction.monitor;
    }
  }

  /// Build stream URL for camera
  String _buildStreamUrl(String cameraId) {
    if (_baseUrl == null) return '';
    
    final baseUrl = _baseUrl!.replaceAll('/api', '');
    return '$baseUrl/cgi-bin/nph-zms?mode=jpeg&monitor=$cameraId&scale=100&maxfps=30';
  }

  /// Get camera by ID
  Future<CameraModel> getCameraById(String cameraId) async {
    try {
      final response = await _dio.get('/api/monitors/$cameraId.json');
      return CameraModel.fromJson(response.data['monitor']);
    } catch (e) {
      throw Exception('Failed to fetch camera $cameraId: $e');
    }
  }

  /// Get camera stream URL
  Future<String> getCameraStreamUrl(String cameraId) async {
    // TODO: Implement proper stream URL generation based on ZM configuration
    return '$_baseUrl/cgi-bin/nph-zms?mode=jpeg&monitor=$cameraId&scale=100&maxfps=30';
  }

  /// Get camera thumbnail URL
  Future<String> getCameraThumbnailUrl(String cameraId) async {
    // TODO: Implement thumbnail URL generation
    return '$_baseUrl/index.php?view=image&eid=0&fid=snapshot&monitor=$cameraId';
  }

  /// Get camera stream status
  Stream<bool> getCameraStreamStatus(String cameraId) async* {
    // TODO: Implement stream status monitoring
    yield true; // Placeholder
  }

  /// Get connection status stream
  Stream<bool> get connectionStatusStream async* {
    // TODO: Implement connection monitoring
    yield true; // Placeholder
  }

  /// Get events list
  Future<List<EventModel>> getEvents({EventsFilters? filters}) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (filters != null) {
        if (filters.cameraId != null) {
          queryParams['MonitorId'] = filters.cameraId;
        }
        if (filters.startDate != null) {
          queryParams['StartDateTime'] = filters.startDate!.toIso8601String();
        }
        if (filters.endDate != null) {
          queryParams['EndDateTime'] = filters.endDate!.toIso8601String();
        }
        if (filters.minAlarmScore != null) {
          queryParams['MinAlarmScore'] = filters.minAlarmScore;
        }
      }
      
      final response = await _dio.get('/events.json', queryParameters: queryParams);
      final data = response.data;
      
      if (data['events'] != null) {
        final eventsData = data['events'] as List;
        return eventsData.map((eventJson) {
          final event = eventJson['Event'];
          return _parseEventFromJson(event);
        }).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  /// Parse event from ZoneMinder JSON
  EventModel _parseEventFromJson(Map<String, dynamic> event) {
    return EventModel(
      id: event['Id'].toString(),
      cameraId: event['MonitorId'].toString(),
      cameraName: event['MonitorName'] ?? 'Unknown Camera',
      name: event['Name'] ?? 'Event',
      cause: event['Cause'] ?? 'Unknown',
      notes: event['Notes'] ?? '',
      startTime: DateTime.parse(event['StartDateTime']),
      endTime: DateTime.parse(event['EndDateTime']),
      length: int.tryParse(event['Length']?.toString() ?? '0') ?? 0,
      frames: int.tryParse(event['Frames']?.toString() ?? '0') ?? 0,
      alarmFrames: int.tryParse(event['AlarmFrames']?.toString() ?? '0') ?? 0,
      maxScore: double.tryParse(event['MaxScore']?.toString() ?? '0') ?? 0.0,
      avgScore: double.tryParse(event['AvgScore']?.toString() ?? '0') ?? 0.0,
      thumbnailPath: '/events/${event['Id']}/snapshot.jpg',
      videoPath: '/events/${event['Id']}/video.mp4',
      state: _parseEventState(event['StateId']),
      archived: event['Archived'] == '1',
    );
  }

  /// Parse event state from ZoneMinder state ID
  EventState _parseEventState(dynamic stateId) {
    switch (stateId?.toString()) {
      case '0':
        return EventState.idle;
      case '1':
        return EventState.alert;
      case '2':
        return EventState.alarm;
      default:
        return EventState.idle;
    }
  }

  /// Take camera snapshot
  Future<void> takeCameraSnapshot(String cameraId) async {
    try {
      await _dio.post('/api/monitors/$cameraId/snapshot.json');
    } catch (e) {
      throw Exception('Failed to take snapshot: $e');
    }
  }

  /// Start camera recording
  Future<void> startCameraRecording(String cameraId) async {
    try {
      await _dio.post('/api/monitors/$cameraId/record.json', data: {'action': 'start'});
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  /// Stop camera recording
  Future<void> stopCameraRecording(String cameraId) async {
    try {
      await _dio.post('/api/monitors/$cameraId/record.json', data: {'action': 'stop'});
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  /// Get PTZ capabilities
  Future<PtzCapabilities> getPtzCapabilities(String cameraId) async {
    try {
      final response = await _dio.get('/api/monitors/$cameraId/ptz.json');
      return PtzCapabilities.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch PTZ capabilities: $e');
    }
  }

  /// Get PTZ presets
  Future<List<PtzPreset>> getPtzPresets(String cameraId) async {
    try {
      final response = await _dio.get('/api/monitors/$cameraId/presets.json');
      final List<dynamic> presetsData = response.data['presets'];
      
      return presetsData.map((preset) => PtzPreset.fromJson(preset)).toList();
    } catch (e) {
      throw Exception('Failed to fetch PTZ presets: $e');
    }
  }

  /// PTZ move command
  Future<void> ptzMove(String cameraId, PtzDirection direction, {double? speed}) async {
    try {
      await _dio.post('/api/monitors/$cameraId/ptz.json', data: {
        'action': 'move',
        'direction': direction.name,
        'speed': speed ?? 1.0,
      });
    } catch (e) {
      throw Exception('Failed to move PTZ: $e');
    }
  }

  /// PTZ stop command
  Future<void> ptzStop(String cameraId) async {
    try {
      await _dio.post('/api/monitors/$cameraId/ptz.json', data: {'action': 'stop'});
    } catch (e) {
      throw Exception('Failed to stop PTZ: $e');
    }
  }

  /// PTZ zoom command
  Future<void> ptzZoom(String cameraId, PtzZoomDirection direction, {double? speed}) async {
    try {
      await _dio.post('/api/monitors/$cameraId/ptz.json', data: {
        'action': 'zoom',
        'direction': direction.name,
        'speed': speed ?? 1.0,
      });
    } catch (e) {
      throw Exception('Failed to zoom PTZ: $e');
    }
  }

  /// PTZ go to preset
  Future<void> ptzGoToPreset(String cameraId, int presetId) async {
    try {
      await _dio.post('/api/monitors/$cameraId/ptz.json', data: {
        'action': 'preset',
        'preset': presetId,
      });
    } catch (e) {
      throw Exception('Failed to go to PTZ preset: $e');
    }
  }

  /// PTZ save preset
  Future<void> ptzSavePreset(String cameraId, int presetId, String name) async {
    try {
      await _dio.post('/api/monitors/$cameraId/presets.json', data: {
        'preset': presetId,
        'name': name,
      });
    } catch (e) {
      throw Exception('Failed to save PTZ preset: $e');
    }
  }

  /// PTZ calibrate
  Future<void> ptzCalibrate(String cameraId) async {
    try {
      await _dio.post('/api/monitors/$cameraId/ptz.json', data: {'action': 'calibrate'});
    } catch (e) {
      throw Exception('Failed to calibrate PTZ: $e');
    }
  }

  /// PTZ go home
  Future<void> ptzGoHome(String cameraId) async {
    try {
      await _dio.post('/api/monitors/$cameraId/ptz.json', data: {'action': 'home'});
    } catch (e) {
      throw Exception('Failed to go PTZ home: $e');
    }
  }

  /// PTZ stop all operations
  Future<void> ptzStopAll(String cameraId) async {
    try {
      await _dio.post('/api/monitors/$cameraId/ptz.json', data: {'action': 'stop_all'});
    } catch (e) {
      throw Exception('Failed to stop all PTZ operations: $e');
    }
  }
}
