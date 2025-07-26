import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/domain/models/camera_model.dart';
import '../../../../core/services/zm_api_service.dart';

/// Provider for camera detail information
/// Fetches detailed camera data for individual camera view
final cameraDetailProvider = AsyncNotifierProvider.family<CameraDetailNotifier, CameraModel, String>(() {
  return CameraDetailNotifier();
});

/// Provider for fullscreen mode state
/// Manages fullscreen video display toggle
final fullscreenModeProvider = StateNotifierProvider<FullscreenNotifier, bool>((ref) {
  return FullscreenNotifier();
});

/// Provider for camera recording state
/// Tracks if camera is currently recording
final cameraRecordingProvider = StateProvider.family<bool, String>((ref, cameraId) {
  return false; // Default to not recording
});

/// Notifier for camera detail state management
class CameraDetailNotifier extends FamilyAsyncNotifier<CameraModel, String> {
  @override
  Future<CameraModel> build(String cameraId) async {
    final apiService = ref.watch(zmApiServiceProvider);
    return await apiService.getCameraById(cameraId);
  }

  /// Take snapshot of current camera view
  Future<void> takeSnapshot() async {
    final apiService = ref.watch(zmApiServiceProvider);
    await apiService.takeCameraSnapshot(arg);
  }

  /// Toggle camera recording state
  Future<void> toggleRecording() async {
    final apiService = ref.watch(zmApiServiceProvider);
    final isRecording = ref.read(cameraRecordingProvider(arg));
    
    if (isRecording) {
      await apiService.stopCameraRecording(arg);
    } else {
      await apiService.startCameraRecording(arg);
    }
    
    ref.read(cameraRecordingProvider(arg).notifier).state = !isRecording;
  }
}

/// Notifier for fullscreen mode management
class FullscreenNotifier extends StateNotifier<bool> {
  FullscreenNotifier() : super(false);

  /// Toggle fullscreen mode
  void toggle() {
    state = !state;
  }

  /// Set fullscreen mode
  void setFullscreen(bool isFullscreen) {
    state = isFullscreen;
  }
}
