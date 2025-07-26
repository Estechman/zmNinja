import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/camera_model.dart';
import 'camera_tile_widget.dart';

/// Widget for displaying cameras in a grid layout
/// Supports different grid configurations and responsive design
class CameraGridWidget extends ConsumerWidget {
  final List<CameraModel> cameras;

  const CameraGridWidget({
    super.key,
    required this.cameras,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 840;
    
    // Calculate responsive grid columns
    int crossAxisCount;
    if (isDesktop) {
      crossAxisCount = cameras.length >= 4 ? 4 : cameras.length;
    } else if (screenSize.width > 600) {
      // Tablet layout
      crossAxisCount = cameras.length >= 3 ? 3 : cameras.length;
    } else {
      // Mobile layout
      crossAxisCount = cameras.length >= 2 ? 2 : 1;
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isDesktop ? 16 : 12,
        mainAxisSpacing: isDesktop ? 16 : 12,
        childAspectRatio: 16 / 9,
      ),
      itemCount: cameras.length,
      itemBuilder: (context, index) {
        final camera = cameras[index];
        
        return GestureDetector(
          onTap: () => context.go('/camera/${camera.id}'),
          onLongPress: () => _showCameraOptions(context, camera),
          child: CameraTileWidget(camera: camera),
        );
      },
    );
  }


  /// Show camera options menu on long press
  void _showCameraOptions(BuildContext context, CameraModel camera) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('View Camera'),
            onTap: () {
              Navigator.pop(context);
              context.go('/camera/${camera.id}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.control_camera),
            title: const Text('PTZ Controls'),
            onTap: () {
              Navigator.pop(context);
              context.go('/ptz/${camera.id}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('View Events'),
            onTap: () {
              Navigator.pop(context);
              context.go('/events?camera=${camera.id}');
            },
          ),
        ],
      ),
    );
  }
}
