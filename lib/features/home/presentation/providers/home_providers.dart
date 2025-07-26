import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/camera_model.dart';
import '../../../../core/services/zm_api_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/websocket_service.dart';

/// Enhanced provider for camera list with optimized caching and real-time updates
/// Fetches cameras from ZoneMinder API with intelligent fallback strategy
final camerasProvider = FutureProvider.autoDispose<List<CameraModel>>((ref) async {
  final apiService = ref.watch(zmApiServiceProvider);
  final storageService = ref.watch(localStorageServiceProvider);
  
  // Keep provider alive for 5 minutes to reduce unnecessary API calls
  ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  
  try {
    // Try to get cameras from ZoneMinder API with timeout
    final cameras = await apiService.getCameras().timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('API request timed out', const Duration(seconds: 10)),
    );
    
    // Cache the cameras for offline use
    await storageService.cacheCameras(cameras);
    
    // Update connection status on successful API call
    ref.read(connectionStatusProvider.notifier).updateConnectionStatus(true);
    
    return cameras;
  } catch (e) {
    // Update connection status on API failure
    ref.read(connectionStatusProvider.notifier).updateConnectionStatus(false);
    
    // Try to get cached cameras first
    try {
      final cachedCameras = await storageService.getCachedCameras();
      if (cachedCameras.isNotEmpty) {
        return cachedCameras;
      }
    } catch (cacheError) {
      // Cache also failed, continue to mock data
    }
    
    // Fallback to mock data if API and cache are not available
    return _getMockCameras();
  }
});

/// Enhanced provider for real-time camera status updates
/// Monitors camera status changes via WebSocket connection
final cameraStatusProvider = StreamProvider.autoDispose<Map<String, CameraStatus>>((ref) async* {
  final websocketService = ref.watch(websocketServiceProvider);
  
  // Initial status map
  Map<String, CameraStatus> statusMap = {};
  
  // Listen to WebSocket events for camera status updates
  await for (final event in websocketService.eventStream) {
    final eventType = event['type'] as String?;
    if (eventType == 'camera_status') {
      final eventData = event['data'] as Map<String, dynamic>? ?? {};
      final cameraId = eventData['camera_id'] as String?;
      final isOnline = eventData['is_online'] as bool? ?? false;
      final isRecording = eventData['is_recording'] as bool? ?? false;
      
      if (cameraId != null) {
        statusMap[cameraId] = CameraStatus(
          isOnline: isOnline,
          isRecording: isRecording,
          lastUpdate: DateTime.now(),
        );
        yield Map.from(statusMap);
      }
    }
  }
});

/// Get mock camera data for fallback scenarios
List<CameraModel> _getMockCameras() {
  return [
    CameraModel(
      id: '1',
      name: 'Front Door (Demo)',
      streamUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      isOnline: true,
      isRecording: true,
      hasPtz: false,
      function: CameraFunction.modect,
      width: 1920,
      height: 1080,
    ),
    CameraModel(
      id: '2',
      name: 'Backyard (Demo)',
      streamUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      isOnline: true,
      isRecording: false,
      hasPtz: true,
      function: CameraFunction.mocord,
      width: 1920,
      height: 1080,
    ),
    CameraModel(
      id: '3',
      name: 'Garage (Demo)',
      streamUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      isOnline: false,
      isRecording: false,
      hasPtz: false,
      function: CameraFunction.monitor,
      width: 1280,
      height: 720,
    ),
    CameraModel(
      id: '4',
      name: 'Side Yard (Demo)',
      streamUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      isOnline: true,
      isRecording: true,
      hasPtz: true,
      function: CameraFunction.record,
      width: 2560,
      height: 1440,
    ),
  ];
}

/// Enhanced provider for ZoneMinder connection status with intelligent monitoring
/// Monitors real-time connection with adaptive polling intervals
final connectionStatusProvider = StateNotifierProvider<ConnectionStatusNotifier, ZmConnectionState>((ref) {
  return ConnectionStatusNotifier(ref);
});

/// Connection status notifier with enhanced monitoring capabilities
class ConnectionStatusNotifier extends StateNotifier<ZmConnectionState> {
  final Ref _ref;
  Timer? _connectionTimer;
  int _failureCount = 0;
  
  ConnectionStatusNotifier(this._ref) : super(const ZmConnectionState.unknown()) {
    _startConnectionMonitoring();
  }
  
  /// Start intelligent connection monitoring with adaptive intervals
  void _startConnectionMonitoring() {
    _testConnection();
  }
  
  /// Test connection with exponential backoff on failures
  Future<void> _testConnection() async {
    final apiService = _ref.read(zmApiServiceProvider);
    
    try {
      final isConnected = await apiService.testConnection().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      
      if (isConnected) {
        _failureCount = 0;
        state = ZmConnectionState.connected(DateTime.now());
        _scheduleNextTest(const Duration(seconds: 30)); // Normal interval
      } else {
        _handleConnectionFailure();
      }
    } catch (e) {
      _handleConnectionFailure();
    }
  }
  
  /// Handle connection failures with exponential backoff
  void _handleConnectionFailure() {
    _failureCount++;
    state = ZmConnectionState.disconnected(DateTime.now(), _failureCount);
    
    // Exponential backoff: 5s, 10s, 20s, 40s, max 60s
    final backoffSeconds = math.min(5 * math.pow(2, _failureCount - 1).toInt(), 60);
    _scheduleNextTest(Duration(seconds: backoffSeconds));
  }
  
  /// Schedule next connection test
  void _scheduleNextTest(Duration delay) {
    _connectionTimer?.cancel();
    _connectionTimer = Timer(delay, _testConnection);
  }
  
  /// Manually update connection status (called from other providers)
  void updateConnectionStatus(bool isConnected) {
    if (isConnected) {
      _failureCount = 0;
      state = ZmConnectionState.connected(DateTime.now());
    } else {
      _failureCount++;
      state = ZmConnectionState.disconnected(DateTime.now(), _failureCount);
    }
  }
  
  /// Force immediate connection test
  void forceConnectionTest() {
    _connectionTimer?.cancel();
    _testConnection();
  }
  
  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
  }
}

/// Enhanced provider for camera refresh with loading state management
/// Provides refresh functionality with loading indicators
final cameraRefreshProvider = StateNotifierProvider<CameraRefreshNotifier, RefreshState>((ref) {
  return CameraRefreshNotifier(ref);
});

/// Enhanced provider for grid layout with persistence
/// Manages camera display layout with user preference storage
final gridLayoutProvider = StateNotifierProvider<GridLayoutNotifier, GridLayout>((ref) {
  return GridLayoutNotifier(ref);
});

/// Provider for camera search and filtering
/// Enables real-time camera filtering by name or status
final cameraSearchProvider = StateProvider<String>((ref) => '');

/// Provider for filtered cameras based on search query
/// Returns cameras filtered by search criteria
final filteredCamerasProvider = Provider<AsyncValue<List<CameraModel>>>((ref) {
  final camerasAsync = ref.watch(camerasProvider);
  final searchQuery = ref.watch(cameraSearchProvider);
  
  return camerasAsync.when(
    data: (cameras) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(cameras);
      }
      
      final filtered = cameras.where((camera) =>
        camera.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        camera.id.contains(searchQuery)
      ).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Camera refresh notifier with loading state management
class CameraRefreshNotifier extends StateNotifier<RefreshState> {
  final Ref _ref;
  
  CameraRefreshNotifier(this._ref) : super(const RefreshState.idle());
  
  /// Refresh cameras with loading state tracking
  Future<void> refreshCameras() async {
    if (state.isLoading) return; // Prevent multiple simultaneous refreshes
    
    state = const RefreshState.loading();
    
    try {
      // Invalidate cameras provider to force refresh
      _ref.invalidate(camerasProvider);
      
      // Wait for the new data to load
      await _ref.read(camerasProvider.future);
      
      state = RefreshState.success(DateTime.now());
      
      // Reset to idle after 2 seconds
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          state = const RefreshState.idle();
        }
      });
    } catch (e) {
      state = RefreshState.error(e.toString());
      
      // Reset to idle after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          state = const RefreshState.idle();
        }
      });
    }
  }
}

/// Grid layout notifier with persistence
class GridLayoutNotifier extends StateNotifier<GridLayout> {
  final Ref _ref;
  
  GridLayoutNotifier(this._ref) : super(GridLayout.auto) {
    _loadSavedLayout();
  }
  
  /// Load saved layout from storage
  Future<void> _loadSavedLayout() async {
    try {
      final storageService = _ref.read(localStorageServiceProvider);
      final savedLayout = await storageService.getGridLayout();
      if (savedLayout != null) {
        state = savedLayout;
      }
    } catch (e) {
      // Use default layout if loading fails
    }
  }
  
  /// Update grid layout and persist to storage
  Future<void> setLayout(GridLayout layout) async {
    state = layout;
    
    try {
      final storageService = _ref.read(localStorageServiceProvider);
      await storageService.saveGridLayout(layout);
    } catch (e) {
      // Continue even if saving fails
    }
  }
  
  /// Get optimal layout based on camera count
  GridLayout getOptimalLayout(int cameraCount) {
    if (state != GridLayout.auto) return state;
    
    if (cameraCount <= 1) return GridLayout.single;
    if (cameraCount <= 4) return GridLayout.quad;
    if (cameraCount <= 9) return GridLayout.nine;
    return GridLayout.sixteen;
  }
}

/// Refresh state for camera operations
class RefreshState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final DateTime? lastRefresh;
  
  const RefreshState._({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.lastRefresh,
  });
  
  const RefreshState.idle() : this._();
  const RefreshState.loading() : this._(isLoading: true);
  RefreshState.success(DateTime timestamp) : this._(isSuccess: true, lastRefresh: timestamp);
  RefreshState.error(String message) : this._(isError: true, errorMessage: message);
}

/// Connection state for ZoneMinder server
class ZmConnectionState {
  final bool isConnected;
  final bool isUnknown;
  final DateTime? lastUpdate;
  final int failureCount;
  
  const ZmConnectionState._({
    this.isConnected = false,
    this.isUnknown = false,
    this.lastUpdate,
    this.failureCount = 0,
  });
  
  const ZmConnectionState.unknown() : this._(isUnknown: true);
  ZmConnectionState.connected(DateTime timestamp) : this._(isConnected: true, lastUpdate: timestamp);
  ZmConnectionState.disconnected(DateTime timestamp, int failures) : 
    this._(isConnected: false, lastUpdate: timestamp, failureCount: failures);
}

/// Camera status for real-time updates
class CameraStatus {
  final bool isOnline;
  final bool isRecording;
  final DateTime lastUpdate;
  
  const CameraStatus({
    required this.isOnline,
    required this.isRecording,
    required this.lastUpdate,
  });
}

/// Enum for different grid layout options
enum GridLayout {
  auto,     // Automatic based on camera count
  single,   // Single camera view
  quad,     // 2x2 grid
  nine,     // 3x3 grid
  sixteen,  // 4x4 grid
}
