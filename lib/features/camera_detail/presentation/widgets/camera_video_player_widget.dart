import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

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
  late VlcPlayerController _vlcController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _vlcController.dispose();
    super.dispose();
  }

  /// Initialize VLC player with camera stream URL
  Future<void> _initializePlayer() async {
    _vlcController = VlcPlayerController.network(
      widget.camera.streamUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(300),
          VlcAdvancedOptions.clockJitter(0),
          // VlcAdvancedOptions.clockSynchro(0), // Method not available in current VLC version
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

    await _vlcController.initialize();
    setState(() {
      _isInitialized = true;
    });
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
          // VLC Player
          VlcPlayer(
            controller: _vlcController,
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
                    _vlcController.value.isPlaying ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _vlcController.value.isPlaying ? 'LIVE' : 'PAUSED',
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

          // Error overlay
          if (_vlcController.value.hasError)
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
