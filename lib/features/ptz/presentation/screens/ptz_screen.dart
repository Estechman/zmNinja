import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ptz_providers.dart';
import '../widgets/ptz_controls_widget.dart';
import '../widgets/ptz_presets_widget.dart';
import '../widgets/camera_preview_widget.dart';

/// PTZ (Pan/Tilt/Zoom) control screen for camera movement
/// Provides directional controls, zoom, and preset positions
class PtzScreen extends ConsumerWidget {
  final String cameraId;

  const PtzScreen({
    super.key,
    required this.cameraId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = ref.watch(ptzCameraProvider(cameraId));
    final ptzCapabilities = ref.watch(ptzCapabilitiesProvider(cameraId));
    final isControlling = ref.watch(ptzControllingProvider);

    return Scaffold(
      appBar: AppBar(
        title: camera.when(
          data: (cam) => Text('PTZ - ${cam.name}'),
          loading: () => const Text('PTZ Controls'),
          error: (_, __) => const Text('PTZ Error'),
        ),
        actions: [
          // PTZ settings menu
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'calibrate',
                child: ListTile(
                  leading: Icon(Icons.tune),
                  title: Text('Calibrate'),
                ),
              ),
              const PopupMenuItem(
                value: 'home',
                child: ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Go Home'),
                ),
              ),
              const PopupMenuItem(
                value: 'stop',
                child: ListTile(
                  leading: Icon(Icons.stop),
                  title: Text('Stop All'),
                ),
              ),
            ],
          ),
        ],
      ),
      
      body: camera.when(
        data: (cam) {
          if (!cam.hasPtz) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.control_camera_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('PTZ Not Supported'),
                  SizedBox(height: 8),
                  Text('This camera does not support PTZ controls'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Camera preview
              Expanded(
                flex: 2,
                child: CameraPreviewWidget(camera: cam),
              ),
              
              // PTZ controls section
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Main PTZ controls (left side)
                      Expanded(
                        flex: 2,
                        child: ptzCapabilities.when(
                          data: (capabilities) => PtzControlsWidget(
                            cameraId: cameraId,
                            capabilities: capabilities,
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, stackTrace) => Center(
                            child: Text('Error loading PTZ capabilities: $error'),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // PTZ presets (right side)
                      Expanded(
                        flex: 1,
                        child: PtzPresetsWidget(cameraId: cameraId),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text('Error loading camera: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(ptzCameraProvider(cameraId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      
      // Status indicator for active PTZ operations
      bottomSheet: isControlling ? Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).primaryColor,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Controlling Camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ) : null,
    );
  }

  /// Handle popup menu actions
  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'calibrate':
        ref.read(ptzControllerProvider(cameraId).notifier).calibrate();
        break;
      case 'home':
        ref.read(ptzControllerProvider(cameraId).notifier).goHome();
        break;
      case 'stop':
        ref.read(ptzControllerProvider(cameraId).notifier).stopAll();
        break;
    }
  }
}
