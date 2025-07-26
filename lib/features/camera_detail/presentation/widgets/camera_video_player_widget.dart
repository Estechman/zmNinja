import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../../../home/domain/models/camera_model.dart';

/// Video player widget for displaying camera streams
/// Uses VLC player for robust video streaming support
class CameraVideoPlayerWidget extends ConsumerStatefulWidget {
  final CameraModel camera;

  const CameraVideoPlayerWidget({
    super.key,
    required this.camera,
  });

  @override
  ConsumerState<CameraVideoPlayerWidget> createState() => _CameraVideoPlayerWidgetState();
}

class _CameraVideoPlayerWidgetState extends ConsumerState<CameraVideoPlayerWidget> {
  VlcPlayerController? _vlcController;
  bool _isInitialized = false;
  bool _isWebMjpeg = false;
  bool _hasStreamError = false;
  int _errorCount = 0;
  Timer? _mjpegRefreshTimer;
  String _mjpegImageKey = '';

  @override
  void initState() {
    super.initState();
    // Initialize player asynchronously to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializePlayer();
      }
    });
  }

  @override
  void dispose() {
    _vlcController?.dispose();
    _mjpegRefreshTimer?.cancel();
    super.dispose();
  }

  /// Initialize player based on stream type and platform
  Future<void> _initializePlayer() async {
    if (!mounted) return;
    
    final streamUrl = widget.camera.streamUrl.toLowerCase();
    
    // On web platform, always use Image.network approach for better compatibility
    if (kIsWeb) {
      _isWebMjpeg = true;
      _startMjpegRefresh();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      return;
    }

    // Use VLC player only on native platforms (iOS, Android, desktop)
    try {
      _vlcController = VlcPlayerController.network(
        widget.camera.streamUrl,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(300),
            VlcAdvancedOptions.clockJitter(0),
          ]),
          video: VlcVideoOptions([
            VlcVideoOptions.dropLateFrames(true),
            VlcVideoOptions.skipFrames(true),
          ]),
          audio: VlcAudioOptions([
            VlcAudioOptions.audioTimeStretch(false),
          ]),
          rtp: VlcRtpOptions([
            VlcRtpOptions.rtpOverRtsp(true),
          ]),
        ),
      );

      await _vlcController!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Fallback to placeholder if VLC fails on native platforms
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasStreamError = true;
        });
      }
    }
  }

  /// Start MJPEG refresh timer for web compatibility
  void _startMjpegRefresh() {
    // Initialize with a timestamp but don't call setState immediately
    _mjpegImageKey = DateTime.now().millisecondsSinceEpoch.toString();
    
    _mjpegRefreshTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_hasStreamError && _errorCount > 5) {
        // Stop refreshing after multiple errors to prevent console spam
        timer.cancel();
        return;
      }
      if (mounted) {
        _updateMjpegKey();
      }
    });
  }

  /// Update MJPEG image key to force refresh
  void _updateMjpegKey() {
    if (!_hasStreamError && mounted) {
      setState(() {
        _mjpegImageKey = DateTime.now().millisecondsSinceEpoch.toString();
      });
    }
  }

  /// Handle stream errors
  void _handleStreamError() {
    if (mounted) {
      setState(() {
        _hasStreamError = true;
        _errorCount++;
      });
    }
  }

  /// Build web-compatible video player
  Widget _buildWebVideoPlayer() {
    final streamUrl = widget.camera.streamUrl.toLowerCase();
    
    // For MP4 streams, use a simple video element approach
    if (streamUrl.endsWith('.mp4')) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_outline, color: Colors.white, size: 80),
              const SizedBox(height: 16),
              Text(
                'Video Player',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.camera.width}x${widget.camera.height} • ${widget.camera.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Demo Video Stream',
                          style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Video streaming placeholder - ${widget.camera.streamUrl}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // For MJPEG and other streams, use Image.network with refresh
    return Image.network(
      '${widget.camera.streamUrl}?t=$_mjpegImageKey',
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Handle error asynchronously to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _handleStreamError();
          }
        });
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_off, color: Colors.white54, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Video Player',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.camera.width}x${widget.camera.height} • ${widget.camera.name}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Stream Unavailable',
                            style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kIsWeb ? 'External streams may be blocked by browser security policies' 
                               : 'Unable to connect to video stream',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Web-compatible video display
          if (_isWebMjpeg)
            Center(
              child: _buildWebVideoPlayer(),
            )
          
          // VLC Player for non-web or non-MJPEG streams
          else if (_vlcController != null)
            VlcPlayer(
              controller: _vlcController!,
              aspectRatio: widget.camera.width / widget.camera.height,
              placeholder: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Stream status overlay
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isWebMjpeg || (_vlcController?.value.isPlaying ?? false) 
                      ? Icons.play_arrow 
                      : Icons.pause,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isWebMjpeg || (_vlcController?.value.isPlaying ?? false) 
                      ? 'LIVE' 
                      : 'PAUSED',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Error overlay for VLC
          if (_vlcController?.value.hasError ?? false)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Stream Error',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Unable to load video stream',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
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
