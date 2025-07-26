import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../home/domain/models/camera_model.dart';
import '../providers/camera_detail_providers.dart';

/// Camera controls widget for basic camera operations
/// Provides buttons for common camera actions
class CameraControlsWidget extends ConsumerWidget {
  final CameraModel camera;

  const CameraControlsWidget({
    super.key,
    required this.camera,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecording = ref.watch(cameraRecordingProvider(camera.id));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Snapshot button
          _ControlButton(
            icon: Icons.camera_alt,
            label: 'Snapshot',
            onPressed: () => ref.read(cameraDetailProvider(camera.id).notifier).takeSnapshot(),
          ),

          // Recording toggle button
          _ControlButton(
            icon: isRecording ? Icons.stop : Icons.fiber_manual_record,
            label: isRecording ? 'Stop' : 'Record',
            color: isRecording ? Colors.red : null,
            onPressed: () => ref.read(cameraDetailProvider(camera.id).notifier).toggleRecording(),
          ),

          // PTZ controls button (if camera supports PTZ)
          if (camera.hasPtz)
            _ControlButton(
              icon: Icons.control_camera,
              label: 'PTZ',
              onPressed: () => context.go('/ptz/${camera.id}'),
            ),

          // Events button
          _ControlButton(
            icon: Icons.event,
            label: 'Events',
            onPressed: () => context.go('/events?camera=${camera.id}'),
          ),

          // Settings button
          _ControlButton(
            icon: Icons.settings,
            label: 'Settings',
            onPressed: () => _showCameraSettings(context, camera),
          ),
        ],
      ),
    );
  }

  /// Show camera settings dialog
  void _showCameraSettings(BuildContext context, CameraModel camera) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${camera.name} Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Camera ID: ${camera.id}'),
            Text('Resolution: ${camera.width}x${camera.height}'),
            Text('Function: ${camera.function.name}'),
            Text('Status: ${camera.isOnline ? 'Online' : 'Offline'}'),
            if (camera.description != null)
              Text('Description: ${camera.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Individual control button widget
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: color,
          iconSize: 28,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
