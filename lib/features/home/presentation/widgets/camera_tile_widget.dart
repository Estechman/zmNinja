import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/camera_model.dart';

/// Individual camera tile widget for grid display
/// Shows live camera feed with status indicators
class CameraTileWidget extends ConsumerWidget {
  final CameraModel camera;

  const CameraTileWidget({
    super.key,
    required this.camera,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 840;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: camera.isOnline ? 4 : 2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera stream placeholder with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: camera.isOnline
                    ? [
                        Colors.grey[800]!,
                        Colors.grey[700]!,
                        Colors.grey[900]!,
                      ]
                    : [
                        Colors.grey[600]!,
                        Colors.grey[500]!,
                        Colors.grey[700]!,
                      ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    camera.isOnline ? Icons.videocam : Icons.videocam_off,
                    color: camera.isOnline ? Colors.white : Colors.grey[400],
                    size: isDesktop ? 56 : 48,
                  ),
                  const SizedBox(height: 8),
                  if (camera.isOnline) ...[
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${camera.width}x${camera.height}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: isDesktop ? 12 : 10,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'OFFLINE',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Status indicators
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Recording indicator
                if (camera.isRecording)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'REC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 10 : 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // PTZ indicator
                if (camera.hasPtz) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.control_camera,
                      color: Colors.white,
                      size: isDesktop ? 14 : 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Camera info overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 16 : 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    camera.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (camera.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      camera.description!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: isDesktop ? 12 : 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        camera.isOnline ? Icons.circle : Icons.circle_outlined,
                        color: camera.isOnline ? Colors.green : Colors.red,
                        size: isDesktop ? 14 : 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        camera.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: isDesktop ? 12 : 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        camera.function.name.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: isDesktop ? 10 : 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
