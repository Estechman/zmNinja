import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../../domain/models/event_model.dart';
import '../../domain/models/alarm_frame_model.dart';

class EventPlayerWidget extends ConsumerStatefulWidget {
  final EventModel event;

  const EventPlayerWidget({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<EventPlayerWidget> createState() => _EventPlayerWidgetState();
}

class _EventPlayerWidgetState extends ConsumerState<EventPlayerWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _currentFrame = 0;
  List<AlarmFrame> _alarmFrames = [];
  bool _showAlarmFramesOnly = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _generateMockAlarmFrames();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializePlayer() async {
    try {
      if (widget.event.videoPath != null) {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse('https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4'),
        );
        
        await _videoController!.initialize();
        
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: false,
          looping: false,
          showControls: true,
          allowFullScreen: true,
          allowMuting: true,
          showControlsOnInitialize: true,
        );
        
        _videoController!.addListener(_onVideoPositionChanged);
        
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  void _generateMockAlarmFrames() {
    final random = Random();
    _alarmFrames = List.generate(15, (index) {
      final frameNumber = random.nextInt(widget.event.frames);
      final timestamp = (frameNumber / 30.0);
      final score = 50 + random.nextDouble() * 50;
      
      return AlarmFrame(
        frameNumber: frameNumber,
        timestamp: timestamp,
        score: score,
        imagePath: '/events/${widget.event.id}/frame_$frameNumber.jpg',
        cause: ['Motion', 'Person', 'Vehicle'][random.nextInt(3)],
      );
    });
    
    _alarmFrames.sort((a, b) => a.frameNumber.compareTo(b.frameNumber));
  }

  void _onVideoPositionChanged() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      final position = _videoController!.value.position;
      final duration = _videoController!.value.duration;
      
      if (duration.inMilliseconds > 0) {
        final progress = position.inMilliseconds / duration.inMilliseconds;
        final newFrame = (progress * widget.event.frames).round();
        
        if (newFrame != _currentFrame) {
          setState(() {
            _currentFrame = newFrame;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _buildVideoPlayer(),
        ),
        Container(
          height: 80,
          child: _buildAlarmFrameTimeline(),
        ),
        Container(
          height: 100,
          child: _buildPlaybackControls(),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isInitialized || _chewieController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Chewie(controller: _chewieController!),
    );
  }

  Widget _buildAlarmFrameTimeline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Alarm Frames:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _alarmFrames.map((frame) {
                  final isSelected = frame.frameNumber == _currentFrame;
                  return GestureDetector(
                    onTap: () => _jumpToFrame(frame.frameNumber),
                    child: Container(
                      width: 60,
                      height: 40,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.red : Colors.grey,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: isSelected ? Colors.red.withOpacity(0.1) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 16,
                            color: _getAlarmColor(frame.score),
                          ),
                          Text(
                            '${frame.frameNumber}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _showAlarmFramesOnly ? Icons.visibility : Icons.visibility_off,
              color: _showAlarmFramesOnly ? Colors.orange : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showAlarmFramesOnly = !_showAlarmFramesOnly;
              });
            },
            tooltip: 'Show alarm frames only',
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: _previousFrame,
            tooltip: 'Previous Frame',
          ),
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayback,
            tooltip: _isPlaying ? 'Pause' : 'Play',
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _nextFrame,
            tooltip: 'Next Frame',
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _jumpToStart,
            tooltip: 'Jump to Start',
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _jumpToEnd,
            tooltip: 'Jump to End',
          ),
          const Spacer(),
          Text(
            'Frame: $_currentFrame / ${widget.event.frames}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Text(
            'Score: ${_getCurrentFrameScore().toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Color _getAlarmColor(double score) {
    if (score >= 80) return Colors.red;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.yellow[700]!;
    return Colors.green;
  }

  bool get _isPlaying {
    return _videoController?.value.isPlaying ?? false;
  }

  void _togglePlayback() {
    if (_videoController != null) {
      if (_isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    }
  }

  void _previousFrame() {
    if (_currentFrame > 0) {
      _jumpToFrame(_currentFrame - 1);
    }
  }

  void _nextFrame() {
    if (_currentFrame < widget.event.frames - 1) {
      _jumpToFrame(_currentFrame + 1);
    }
  }

  void _jumpToFrame(int frameNumber) {
    if (_videoController != null && _videoController!.value.isInitialized) {
      final duration = _videoController!.value.duration;
      final progress = frameNumber / widget.event.frames;
      final position = Duration(
        milliseconds: (duration.inMilliseconds * progress).round(),
      );
      
      _videoController!.seekTo(position);
      setState(() {
        _currentFrame = frameNumber;
      });
    }
  }

  void _jumpToStart() {
    _jumpToFrame(0);
  }

  void _jumpToEnd() {
    _jumpToFrame(widget.event.frames - 1);
  }

  double _getCurrentFrameScore() {
    final alarmFrame = _alarmFrames.firstWhere(
      (frame) => frame.frameNumber == _currentFrame,
      orElse: () => const AlarmFrame(
        frameNumber: 0,
        timestamp: 0.0,
        score: 0.0,
        imagePath: '',
      ),
    );
    return alarmFrame.score;
  }
}
