import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../home/domain/models/camera_model.dart';
import '../widgets/camera_controls_widget.dart';

/// Camera detail screen for individual camera viewing
/// Displays full-screen camera feed with controls
class CameraDetailScreen extends ConsumerStatefulWidget {
  final String cameraId;

  const CameraDetailScreen({
    super.key,
    required this.cameraId,
  });

  @override
  ConsumerState<CameraDetailScreen> createState() => _CameraDetailScreenState();
}

class _CameraDetailScreenState extends ConsumerState<CameraDetailScreen> {
  bool _isFullscreen = false;
  bool _showControls = true;

  // Mock camera data
  late CameraModel _mockCamera;

  @override
  void initState() {
    super.initState();
    _mockCamera = CameraModel(
      id: widget.cameraId,
      name: 'Camera ${widget.cameraId}',
      streamUrl: 'rtsp://demo.stream/camera${widget.cameraId}',
      isOnline: true,
      isRecording: widget.cameraId == '1' || widget.cameraId == '4',
      width: 1920,
      height: 1080,
      hasPtz: widget.cameraId == '2' || widget.cameraId == '4',
      function: CameraFunction.modect,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen ? null : AppBar(
        title: Text(_mockCamera.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // PTZ controls navigation
          if (_mockCamera.hasPtz)
            IconButton(
              icon: const Icon(Icons.control_camera),
              onPressed: () => context.go('/ptz/${widget.cameraId}'),
              tooltip: 'PTZ Controls',
            ),
          
          // Fullscreen toggle
          IconButton(
            icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: _toggleFullscreen,
            tooltip: 'Toggle Fullscreen',
          ),
          
          // Camera settings menu
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'snapshot',
                child: ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take Snapshot'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'record',
                child: ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text('Start Recording'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'events',
                child: ListTile(
                  leading: Icon(Icons.event),
                  title: Text('View Events'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      
      body: GestureDetector(
        onTap: () {
          if (_isFullscreen) {
            setState(() {
              _showControls = !_showControls;
            });
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main video player placeholder
            Container(
              color: Colors.black,
              child: Center(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Mock video feed with animated gradient
                    AnimatedContainer(
                      duration: const Duration(seconds: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[800]!,
                            Colors.grey[700]!,
                            Colors.grey[900]!,
                          ],
                        ),
                      ),
                    ),
                    
                    // Video placeholder content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Live Stream Placeholder',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_mockCamera.width}x${_mockCamera.height} • ${_mockCamera.name}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stream status overlay
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Recording indicator
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'REC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Camera controls (if not in fullscreen or controls are visible)
            if (!_isFullscreen || _showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _isFullscreen && !_showControls ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: CameraControlsWidget(camera: _mockCamera),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Toggle fullscreen mode
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  /// Handle popup menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'snapshot':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Snapshot taken')),
        );
        break;
      case 'record':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording started')),
        );
        break;
      case 'events':
        context.go('/events?camera=${widget.cameraId}');
        break;
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}
