import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/ptz_capabilities_model.dart';
import '../providers/ptz_providers.dart';

/// PTZ controls widget for camera movement
/// Provides directional pad and zoom controls
class PtzControlsWidget extends ConsumerWidget {
  final String cameraId;
  final PtzCapabilities capabilities;

  const PtzControlsWidget({
    super.key,
    required this.cameraId,
    required this.capabilities,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isControlling = ref.watch(ptzControllingProvider);

    return Column(
      children: [
        // Movement controls
        if (capabilities.canMove) ...[
          Text(
            'Movement',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          // Directional pad
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              children: [
                // Up
                Positioned(
                  top: 0,
                  left: 70,
                  child: _DirectionalButton(
                    icon: Icons.keyboard_arrow_up,
                    onPressed: isControlling ? null : () => _move(ref, PtzDirection.up),
                  ),
                ),
                
                // Down
                Positioned(
                  bottom: 0,
                  left: 70,
                  child: _DirectionalButton(
                    icon: Icons.keyboard_arrow_down,
                    onPressed: isControlling ? null : () => _move(ref, PtzDirection.down),
                  ),
                ),
                
                // Left
                Positioned(
                  left: 0,
                  top: 70,
                  child: _DirectionalButton(
                    icon: Icons.keyboard_arrow_left,
                    onPressed: isControlling ? null : () => _move(ref, PtzDirection.left),
                  ),
                ),
                
                // Right
                Positioned(
                  right: 0,
                  top: 70,
                  child: _DirectionalButton(
                    icon: Icons.keyboard_arrow_right,
                    onPressed: isControlling ? null : () => _move(ref, PtzDirection.right),
                  ),
                ),
                
                // Up-Left
                Positioned(
                  top: 20,
                  left: 20,
                  child: _DirectionalButton(
                    icon: Icons.north_west,
                    onPressed: isControlling ? null : () => _move(ref, PtzDirection.upLeft),
                    size: 40,
                  ),
                ),
                
                // Up-Right
                Positioned(
                  top: 20,
                  right: 20,
                  child: _DirectionalButton(
                    icon: Icons.north_east,
                    onPressed: isControlling ? null : () => _move(ref, PtzDirection.upRight),
                    size: 40,
                  ),
                ),
                
                // Down-Left
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: _DirectionalButton(
                    icon: Icons.south_west,
                    onPressed: isControlling ? null : () => _move(ref, PtzDirection.downLeft),
                    size: 40,
                  ),
                ),
                
                // Down-Right
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: _DirectionalButton(
                    icon: Icons.south_east,
                    onPressed: isControlling ? null : () => _move(ref, PtzDirection.downRight),
                    size: 40,
                  ),
                ),
                
                // Center stop button
                Positioned(
                  top: 70,
                  left: 70,
                  child: _DirectionalButton(
                    icon: Icons.stop,
                    onPressed: () => _stop(ref),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Zoom controls
        if (capabilities.canZoom) ...[
          Text(
            'Zoom',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: isControlling ? null : () => _zoom(ref, PtzZoomDirection.zoomOut),
                icon: const Icon(Icons.zoom_out),
                label: const Text('Zoom Out'),
              ),
              ElevatedButton.icon(
                onPressed: isControlling ? null : () => _zoom(ref, PtzZoomDirection.zoomIn),
                icon: const Icon(Icons.zoom_in),
                label: const Text('Zoom In'),
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),

        // Additional controls
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (capabilities.canHome)
              ElevatedButton.icon(
                onPressed: isControlling ? null : () => _goHome(ref),
                icon: const Icon(Icons.home),
                label: const Text('Home'),
              ),
            
            if (capabilities.canReset)
              ElevatedButton.icon(
                onPressed: isControlling ? null : () => _calibrate(ref),
                icon: const Icon(Icons.tune),
                label: const Text('Calibrate'),
              ),
            
            ElevatedButton.icon(
              onPressed: () => _stopAll(ref),
              icon: const Icon(Icons.stop),
              label: const Text('Stop All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Move camera in specified direction
  void _move(WidgetRef ref, PtzDirection direction) {
    ref.read(ptzControllerProvider(cameraId).notifier).move(direction);
  }

  /// Stop camera movement
  void _stop(WidgetRef ref) {
    ref.read(ptzControllerProvider(cameraId).notifier).stop();
  }

  /// Zoom camera
  void _zoom(WidgetRef ref, PtzZoomDirection direction) {
    ref.read(ptzControllerProvider(cameraId).notifier).zoom(direction);
  }

  /// Go to home position
  void _goHome(WidgetRef ref) {
    ref.read(ptzControllerProvider(cameraId).notifier).goHome();
  }

  /// Calibrate PTZ
  void _calibrate(WidgetRef ref) {
    ref.read(ptzControllerProvider(cameraId).notifier).calibrate();
  }

  /// Stop all PTZ operations
  void _stopAll(WidgetRef ref) {
    ref.read(ptzControllerProvider(cameraId).notifier).stopAll();
  }
}

/// Individual directional button widget
class _DirectionalButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const _DirectionalButton({
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Icon(
          icon,
          size: size * 0.4,
          color: color != null ? Colors.white : null,
        ),
      ),
    );
  }
}
