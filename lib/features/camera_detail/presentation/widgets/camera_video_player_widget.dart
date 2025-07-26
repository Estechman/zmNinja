import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';

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
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isWebMjpeg = false;
  bool _isWebHls = false;
  bool _hasStreamError = false;
  int _errorCount = 0;
  Timer? _mjpegRefreshTimer;
  String _mjpegImageKey = '';
  bool _useVideoPlayer = false;
  String? _connKey;
  int _maxFps = 5;

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
    _chewieController?.dispose();
    _videoController?.dispose();
    _mjpegRefreshTimer?.cancel();
    super.dispose();
  }

  /// Generate connection key for stream control (based on original zmNinja genConnKey)
  void _generateConnectionKey() {
    final random = Random();
    _connKey = (100000 + random.nextInt(900000)).toString();
  }

  /// Build stream URL with connection key and parameters (based on original zmNinja)
  String _buildStreamUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final queryParams = Map<String, String>.from(uri.queryParameters);
    
    // Add connection key for stream control (based on original zmNinja genConnKey)
    if (_connKey != null) {
      queryParams['connkey'] = _connKey!;
    }
    
    // Add FPS limiting for bandwidth management (original zmNinja maxfps)
    queryParams['maxfps'] = _maxFps.toString();
    
    // For MJPEG streams, ensure mode=jpeg (original zmNinja live streaming)
    if (baseUrl.contains('nph-zms') && !queryParams.containsKey('mode')) {
      queryParams['mode'] = 'jpeg';
    }
    
    // For external MJPEG streams, add cache busting parameter
    if (baseUrl.contains('mjpg') || baseUrl.contains('mjpeg')) {
      queryParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    final finalUrl = uri.replace(queryParameters: queryParams).toString();
    print('DEBUG: Built stream URL: $finalUrl from base: $baseUrl');
    return finalUrl;
  }

  /// Initialize player based on stream type and platform
  Future<void> _initializePlayer() async {
    if (!mounted) return;
    
    // Generate connection key for stream control (based on original zmNinja)
    _generateConnectionKey();
    
    final streamUrl = widget.camera.streamUrl.toLowerCase();
    print('DEBUG: Initializing player for URL: $streamUrl');
    print('DEBUG: Original camera URL: ${widget.camera.streamUrl}');
    print('DEBUG: Platform is web: $kIsWeb');
    
    // On web platform, use appropriate player based on stream type
    if (kIsWeb) {
      // For MJPEG streams, use Image.network approach (original zmNinja mode=jpeg)
      // Check this first since MJPEG is most common for ZoneMinder
      if (streamUrl.contains('mjpg') || streamUrl.contains('mjpeg') || streamUrl.contains('nph-zms')) {
        print('DEBUG: Detected MJPEG stream, setting up web MJPEG');
        if (mounted) {
          setState(() {
            _isWebMjpeg = true;
            _isInitialized = true;
          });
        }
        _startMjpegRefresh();
        print('DEBUG: MJPEG initialization complete, _isWebMjpeg: $_isWebMjpeg, _isInitialized: $_isInitialized');
        return;
      }
      
      // For HLS streams (.m3u8), use video_player which supports HLS on web
      if (streamUrl.contains('.m3u8') || streamUrl.contains('hls')) {
        print('DEBUG: Detected HLS stream, initializing video player');
        await _initializeVideoPlayer();
        return;
      }
      
      // For MP4 and other video formats, try video_player
      if (streamUrl.contains('.mp4') || streamUrl.contains('video')) {
        print('DEBUG: Detected MP4/video stream, initializing video player');
        await _initializeVideoPlayer();
        return;
      }
      
      // Default fallback to MJPEG approach for unknown streams
      print('DEBUG: Using fallback MJPEG approach for unknown stream type');
      if (mounted) {
        setState(() {
          _isWebMjpeg = true;
          _isInitialized = true;
        });
      }
      _startMjpegRefresh();
      print('DEBUG: Fallback initialization complete, _isWebMjpeg: $_isWebMjpeg, _isInitialized: $_isInitialized');
      return;
    }

    // Use VLC player only on native platforms (iOS, Android, desktop)
    try {
      _vlcController = VlcPlayerController.network(
        _buildStreamUrl(widget.camera.streamUrl),
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

  /// Initialize video player for HLS and MP4 streams
  /// Based on original zmNinja live streaming configurations
  Future<void> _initializeVideoPlayer() async {
    try {
      final enhancedUrl = _buildStreamUrl(widget.camera.streamUrl);
      print('DEBUG: Initializing video player with URL: $enhancedUrl');
      
      final isHlsStream = enhancedUrl.contains('.m3u8') || enhancedUrl.contains('hls');
      
      // For HLS streams on web, use InAppWebView approach since video_player doesn't support HLS on web
      if (kIsWeb && isHlsStream) {
        print('DEBUG: Using InAppWebView for HLS stream on web: $enhancedUrl');
        if (mounted) {
          setState(() {
            _isWebHls = true;
            _isInitialized = true;
          });
        }
        print('DEBUG: HLS web player initialization complete, _isWebHls: $_isWebHls, _isInitialized: $_isInitialized');
        return;
      }
      
      // For non-web platforms or non-HLS streams, try video_player
      if (isHlsStream) {
        print('DEBUG: Attempting video_player for HLS stream: $enhancedUrl');
      }
      
      // Use video_player for all video streams (HLS, MP4, etc.)
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(enhancedUrl),
        httpHeaders: {
          'User-Agent': 'zmNinja Flutter App',
          'Accept': '*/*',
        },
      );
      
      await _videoController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: false,
        aspectRatio: widget.camera.width / widget.camera.height,
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Video Stream Error',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
      
      if (mounted) {
        setState(() {
          _useVideoPlayer = true;
          _isInitialized = true;
        });
      }
      print('DEBUG: Video player initialization complete, _useVideoPlayer: $_useVideoPlayer, _isInitialized: $_isInitialized');
    } catch (e) {
      print('DEBUG: Video player initialization failed: $e');
      
      final enhancedUrl = _buildStreamUrl(widget.camera.streamUrl);
      final isHlsStream = enhancedUrl.contains('.m3u8') || enhancedUrl.contains('hls');
      
      // If video_player failed for HLS on web, fall back to InAppWebView approach
      if (kIsWeb && isHlsStream) {
        print('DEBUG: Falling back to InAppWebView for HLS stream on web after video_player failure');
        if (mounted) {
          setState(() {
            _isWebHls = true;
            _isInitialized = true;
          });
        }
        print('DEBUG: HLS web fallback initialization complete, _isWebHls: $_isWebHls, _isInitialized: $_isInitialized');
        return;
      }
      
      // For other failures, set error state
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
    print('DEBUG: Starting MJPEG refresh with key: $_mjpegImageKey');
    
    // Use maxfps to control refresh rate (original zmNinja pattern)
    final refreshInterval = (1000 / _maxFps).round();
    print('DEBUG: MJPEG refresh interval: ${refreshInterval}ms (maxfps: $_maxFps)');
    
    _mjpegRefreshTimer = Timer.periodic(Duration(milliseconds: refreshInterval), (timer) {
      if (_hasStreamError && _errorCount > 5) {
        // Stop refreshing after multiple errors to prevent console spam
        print('DEBUG: Stopping MJPEG refresh due to errors (count: $_errorCount)');
        timer.cancel();
        return;
      }
      if (mounted && _isWebMjpeg) {
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
    final streamUrl = _buildStreamUrl(widget.camera.streamUrl);
    
    // For HLS streams on web, use InAppWebView with HLS.js
    if (_isWebHls && (streamUrl.contains('.m3u8') || streamUrl.contains('hls'))) {
      return _buildHlsWebPlayer(streamUrl);
    }
    
    // For MP4 streams, use InAppWebView with HTML5 video
    if (streamUrl.endsWith('.mp4')) {
      return _buildVideoWebPlayer(streamUrl);
    }
    
    // For MJPEG streams, use InAppWebView for CORS-resistant streaming
    return _buildMjpegWebPlayer(streamUrl);
  }

  /// Build web-compatible HLS video player using InAppWebView
  Widget _buildHlsWebPlayer(String streamUrl) {
    print('DEBUG: Building HLS web player for: $streamUrl');
    
    // Create HTML content with HLS.js for web HLS playback
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>HLS Player</title>
        <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
        <style>
            body {
                margin: 0;
                padding: 0;
                background: #000;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
            }
            video {
                width: 100%;
                height: 100%;
                object-fit: contain;
            }
        </style>
    </head>
    <body>
        <video id="video" controls autoplay muted playsinline></video>
        <script>
            var video = document.getElementById('video');
            var videoSrc = '$streamUrl';
            
            if (Hls.isSupported()) {
                var hls = new Hls({
                    enableWorker: true,
                    lowLatencyMode: true,
                    backBufferLength: 90
                });
                hls.loadSource(videoSrc);
                hls.attachMedia(video);
                hls.on(Hls.Events.MANIFEST_PARSED, function() {
                    video.play();
                });
                hls.on(Hls.Events.ERROR, function(event, data) {
                    console.error('HLS Error:', data);
                });
            } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
                video.src = videoSrc;
                video.addEventListener('loadedmetadata', function() {
                    video.play();
                });
            } else {
                console.error('HLS not supported');
                document.body.innerHTML = '<div style="color: white; text-align: center; padding: 20px;">HLS playback not supported in this browser</div>';
            }
        </script>
    </body>
    </html>
    ''';
    
    return InAppWebView(
      initialData: InAppWebViewInitialData(data: htmlContent),
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        transparentBackground: true,
        supportZoom: false,
        disableContextMenu: true,
        clearCache: true,
      ),
      onWebViewCreated: (controller) {
        print('DEBUG: HLS WebView created successfully');
      },
      onLoadStop: (controller, url) {
        print('DEBUG: HLS WebView loaded: $url');
      },
      onConsoleMessage: (controller, consoleMessage) {
        print('DEBUG: HLS WebView Console: ${consoleMessage.message}');
      },
    );
  }

  /// Build video player for MP4 and other video streams on web
  Widget _buildVideoWebPlayer(String streamUrl) {
    print('DEBUG: Building video web player for: $streamUrl');
    
    // Create simple HTML5 video player for MP4 streams
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Video Player</title>
        <style>
            body {
                margin: 0;
                padding: 0;
                background: #000;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
            }
            video {
                width: 100%;
                height: 100%;
                object-fit: contain;
            }
        </style>
    </head>
    <body>
        <video controls autoplay muted playsinline>
            <source src="$streamUrl" type="video/mp4">
            Your browser does not support the video tag.
        </video>
    </body>
    </html>
    ''';
    
    return InAppWebView(
      initialData: InAppWebViewInitialData(data: htmlContent),
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        transparentBackground: true,
        supportZoom: false,
        disableContextMenu: true,
      ),
      onWebViewCreated: (controller) {
        print('DEBUG: Video WebView created successfully');
      },
      onLoadStop: (controller, url) {
        print('DEBUG: Video WebView loaded: $url');
      },
    );
  }

  /// Build MJPEG web player using InAppWebView for CORS-resistant streaming
  Widget _buildMjpegWebPlayer(String streamUrl) {
    print('DEBUG: Building MJPEG web player for: $streamUrl');
    
    // Create HTML content with auto-refreshing MJPEG image
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>MJPEG Player</title>
        <style>
            body {
                margin: 0;
                padding: 0;
                background: #000;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                overflow: hidden;
            }
            img {
                max-width: 100%;
                max-height: 100%;
                object-fit: contain;
                display: block;
            }
            .loading {
                color: white;
                text-align: center;
                font-family: Arial, sans-serif;
            }
        </style>
    </head>
    <body>
        <div id="loading" class="loading">Loading MJPEG stream...</div>
        <img id="mjpegImage" style="display: none;" />
        <script>
            var img = document.getElementById('mjpegImage');
            var loading = document.getElementById('loading');
            var streamUrl = '$streamUrl';
            var refreshInterval = ${(1000 / _maxFps).round()};
            
            function updateImage() {
                var timestamp = new Date().getTime();
                var separator = streamUrl.includes('?') ? '&' : '?';
                img.src = streamUrl + separator + 't=' + timestamp;
            }
            
            img.onload = function() {
                loading.style.display = 'none';
                img.style.display = 'block';
                console.log('MJPEG frame loaded successfully');
            };
            
            img.onerror = function() {
                console.error('MJPEG frame load error');
                loading.innerHTML = 'Stream connection error';
                loading.style.color = '#ff6b6b';
            };
            
            // Initial load
            updateImage();
            
            // Set up refresh timer based on maxfps
            setInterval(updateImage, refreshInterval);
            
            console.log('MJPEG player initialized with refresh interval: ' + refreshInterval + 'ms');
        </script>
    </body>
    </html>
    ''';
    
    return InAppWebView(
      initialData: InAppWebViewInitialData(data: htmlContent),
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        transparentBackground: true,
        supportZoom: false,
        disableContextMenu: true,
        clearCache: false, // Allow caching for better MJPEG performance
      ),
      onWebViewCreated: (controller) {
        print('DEBUG: MJPEG WebView created successfully');
      },
      onLoadStop: (controller, url) {
        print('DEBUG: MJPEG WebView loaded: $url');
      },
      onConsoleMessage: (controller, consoleMessage) {
        print('DEBUG: MJPEG WebView Console: ${consoleMessage.message}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: Building widget - _isInitialized: $_isInitialized, _useVideoPlayer: $_useVideoPlayer, _isWebMjpeg: $_isWebMjpeg, _isWebHls: $_isWebHls, _chewieController: ${_chewieController != null}, _vlcController: ${_vlcController != null}');
    
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
          // Video player for HLS/MP4 streams on web
          if (_useVideoPlayer && _chewieController != null)
            Chewie(controller: _chewieController!)
          
          // Web-compatible MJPEG display
          else if (_isWebMjpeg)
            Center(
              child: _buildWebVideoPlayer(),
            )
          
          // Web-compatible HLS display using InAppWebView
          else if (_isWebHls)
            Center(
              child: _buildHlsWebPlayer(_buildStreamUrl(widget.camera.streamUrl)),
            )
          
          // Fallback display when no player is active
          else
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'No Video Player Active',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Debug: _useVideoPlayer: $_useVideoPlayer, _isWebMjpeg: $_isWebMjpeg, _isWebHls: $_isWebHls',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          
          // VLC Player for non-web or non-MJPEG streams
          if (_vlcController != null)
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
                    _isWebMjpeg || _isWebHls || (_vlcController?.value.isPlaying ?? false) || (_videoController?.value.isPlaying ?? false)
                      ? Icons.play_arrow 
                      : Icons.pause,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isWebMjpeg || _isWebHls || (_vlcController?.value.isPlaying ?? false) || (_videoController?.value.isPlaying ?? false)
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
