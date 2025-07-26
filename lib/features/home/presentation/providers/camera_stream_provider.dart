import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/zm_api_service.dart';

/// Provider for individual camera stream URLs
/// Manages live video stream URLs for each camera
final cameraStreamProvider = FutureProvider.family<String, String>((ref, cameraId) async {
  final apiService = ref.watch(zmApiServiceProvider);
  return await apiService.getCameraStreamUrl(cameraId);
});

/// Provider for camera thumbnail URLs
/// Provides static thumbnail images for cameras
final cameraThumbnailProvider = FutureProvider.family<String, String>((ref, cameraId) async {
  final apiService = ref.watch(zmApiServiceProvider);
  return await apiService.getCameraThumbnailUrl(cameraId);
});

/// Provider for camera stream status
/// Monitors if camera stream is active and accessible
final cameraStreamStatusProvider = StreamProvider.family<bool, String>((ref, cameraId) {
  final apiService = ref.watch(zmApiServiceProvider);
  return apiService.getCameraStreamStatus(cameraId);
});
