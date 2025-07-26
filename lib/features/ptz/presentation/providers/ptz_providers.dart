import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/ptz_capabilities_model.dart';
import '../../domain/models/ptz_preset_model.dart';
import '../../../home/domain/models/camera_model.dart';
import '../../../../core/services/zm_api_service.dart';

/// Provider for PTZ camera information
/// Fetches camera data specifically for PTZ operations
final ptzCameraProvider = FutureProvider.family<CameraModel, String>((ref, cameraId) async {
  final apiService = ref.watch(zmApiServiceProvider);
  return await apiService.getCameraById(cameraId);
});

/// Provider for PTZ capabilities
/// Fetches supported PTZ operations for a camera
final ptzCapabilitiesProvider = FutureProvider.family<PtzCapabilities, String>((ref, cameraId) async {
  final apiService = ref.watch(zmApiServiceProvider);
  return await apiService.getPtzCapabilities(cameraId);
});

/// Provider for PTZ presets
/// Manages saved camera positions
final ptzPresetsProvider = FutureProvider.family<List<PtzPreset>, String>((ref, cameraId) async {
  final apiService = ref.watch(zmApiServiceProvider);
  return await apiService.getPtzPresets(cameraId);
});

/// Provider for PTZ controller
/// Manages PTZ operations and state
final ptzControllerProvider = AsyncNotifierProvider.family<PtzController, void, String>(() {
  return PtzController();
});

/// Provider for PTZ controlling state
/// Tracks if PTZ operation is in progress
final ptzControllingProvider = StateProvider<bool>((ref) {
  return false;
});

/// Provider for current PTZ position
/// Tracks camera's current pan/tilt/zoom position
final ptzPositionProvider = StateProvider.family<PtzPosition?, String>((ref, cameraId) {
  return null;
});

/// PTZ controller notifier for managing camera movements
class PtzController extends FamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String cameraId) async {
    // Initialize PTZ controller
  }

  /// Move camera in specified direction
  Future<void> move(PtzDirection direction, {double? speed}) async {
    ref.read(ptzControllingProvider.notifier).state = true;
    
    try {
      final apiService = ref.watch(zmApiServiceProvider);
      await apiService.ptzMove(arg, direction, speed: speed);
    } finally {
      ref.read(ptzControllingProvider.notifier).state = false;
    }
  }

  /// Stop camera movement
  Future<void> stop() async {
    final apiService = ref.watch(zmApiServiceProvider);
    await apiService.ptzStop(arg);
    ref.read(ptzControllingProvider.notifier).state = false;
  }

  /// Zoom camera in/out
  Future<void> zoom(PtzZoomDirection direction, {double? speed}) async {
    ref.read(ptzControllingProvider.notifier).state = true;
    
    try {
      final apiService = ref.watch(zmApiServiceProvider);
      await apiService.ptzZoom(arg, direction, speed: speed);
    } finally {
      ref.read(ptzControllingProvider.notifier).state = false;
    }
  }

  /// Go to preset position
  Future<void> goToPreset(int presetId) async {
    ref.read(ptzControllingProvider.notifier).state = true;
    
    try {
      final apiService = ref.watch(zmApiServiceProvider);
      await apiService.ptzGoToPreset(arg, presetId);
    } finally {
      ref.read(ptzControllingProvider.notifier).state = false;
    }
  }

  /// Save current position as preset
  Future<void> savePreset(int presetId, String name) async {
    final apiService = ref.watch(zmApiServiceProvider);
    await apiService.ptzSavePreset(arg, presetId, name);
    ref.invalidate(ptzPresetsProvider(arg));
  }

  /// Calibrate PTZ camera
  Future<void> calibrate() async {
    ref.read(ptzControllingProvider.notifier).state = true;
    
    try {
      final apiService = ref.watch(zmApiServiceProvider);
      await apiService.ptzCalibrate(arg);
    } finally {
      ref.read(ptzControllingProvider.notifier).state = false;
    }
  }

  /// Go to home position
  Future<void> goHome() async {
    ref.read(ptzControllingProvider.notifier).state = true;
    
    try {
      final apiService = ref.watch(zmApiServiceProvider);
      await apiService.ptzGoHome(arg);
    } finally {
      ref.read(ptzControllingProvider.notifier).state = false;
    }
  }

  /// Stop all PTZ operations
  Future<void> stopAll() async {
    final apiService = ref.watch(zmApiServiceProvider);
    await apiService.ptzStopAll(arg);
    ref.read(ptzControllingProvider.notifier).state = false;
  }
}

/// PTZ direction enum
enum PtzDirection {
  up,
  down,
  left,
  right,
  upLeft,
  upRight,
  downLeft,
  downRight,
}

/// PTZ zoom direction enum
enum PtzZoomDirection {
  zoomIn,
  zoomOut,
}

/// PTZ position data class
class PtzPosition {
  final double pan;
  final double tilt;
  final double zoom;

  const PtzPosition({
    required this.pan,
    required this.tilt,
    required this.zoom,
  });
}
