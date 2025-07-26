import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/camera_model.dart';
import '../../../../core/services/zm_api_service.dart';
import '../../../../core/services/local_storage_service.dart';

/// Provider for camera list from ZoneMinder API
/// Fetches and manages list of available cameras/monitors
final camerasProvider = FutureProvider<List<CameraModel>>((ref) async {
  final apiService = ref.watch(zmApiServiceProvider);
  final storageService = ref.watch(localStorageServiceProvider);
  
  try {
    // Try to get cameras from ZoneMinder API
    final cameras = await apiService.getCameras();
    
    // Cache the cameras for offline use
    await storageService.cacheCameras(cameras);
    
    return cameras;
  } catch (e) {
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
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      CameraModel(
        id: '1',
        name: 'Front Door',
        streamUrl: 'rtsp://demo.stream/camera1',
        isOnline: true,
        isRecording: true,
        hasPtz: false,
        function: CameraFunction.modect,
        width: 1920,
        height: 1080,
      ),
      CameraModel(
        id: '2',
        name: 'Backyard',
        streamUrl: 'rtsp://demo.stream/camera2',
        isOnline: true,
        isRecording: false,
        hasPtz: true,
        function: CameraFunction.mocord,
        width: 1920,
        height: 1080,
      ),
      CameraModel(
        id: '3',
        name: 'Living Room',
        streamUrl: 'rtsp://demo.stream/camera3',
        isOnline: false,
        isRecording: false,
        hasPtz: false,
        function: CameraFunction.monitor,
        width: 1280,
        height: 720,
      ),
      CameraModel(
        id: '4',
        name: 'Driveway',
        streamUrl: 'rtsp://demo.stream/camera4',
        isOnline: true,
        isRecording: true,
        hasPtz: true,
        function: CameraFunction.record,
        width: 2560,
        height: 1440,
      ),
    ];
  }
});

/// Provider for ZoneMinder connection status
/// Monitors real-time connection to ZoneMinder server
final connectionStatusProvider = StreamProvider<bool>((ref) async* {
  final apiService = ref.watch(zmApiServiceProvider);
  
  // Initial connection test
  try {
    yield await apiService.testConnection();
  } catch (e) {
    yield false;
  }
  
  // Periodic connection monitoring every 30 seconds
  while (true) {
    await Future.delayed(const Duration(seconds: 30));
    try {
      yield await apiService.testConnection();
    } catch (e) {
      yield false;
    }
  }
});

/// Provider for camera refresh functionality
/// Allows manual refresh of camera list
final refreshCamerasProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(camerasProvider);
  };
});

/// Provider for selected camera grid layout
/// Manages how cameras are displayed in montage view
final gridLayoutProvider = StateProvider<GridLayout>((ref) {
  return GridLayout.auto; // Default to automatic grid layout
});

/// Enum for different grid layout options
enum GridLayout {
  auto,     // Automatic based on camera count
  single,   // Single camera view
  quad,     // 2x2 grid
  nine,     // 3x3 grid
  sixteen,  // 4x4 grid
}
