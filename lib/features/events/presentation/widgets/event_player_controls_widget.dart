import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/alarm_frame_model.dart';
import '../providers/events_providers.dart';

/// Event player controls widget with alarm frame navigation
/// Replicates original zmNinja's frame-by-frame playback functionality
class EventPlayerControlsWidget extends ConsumerStatefulWidget {
  final EventModel event;
  final List<AlarmFrame> alarmFrames;
  final int currentFrame;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final ValueChanged<int>? onFrameChanged;
  final bool isPlaying;

  const EventPlayerControlsWidget({
    super.key,
    required this.event,
    required this.alarmFrames,
    required this.currentFrame,
    this.onPrevious,
    this.onNext,
    this.onPlay,
    this.onPause,
    this.onFrameChanged,
    this.isPlaying = false,
  });

  @override
  ConsumerState<EventPlayerControlsWidget> createState() => _EventPlayerControlsWidgetState();
}

class _EventPlayerControlsWidgetState extends ConsumerState<EventPlayerControlsWidget> {
  bool _showAlarmFramesOnly = false;
  double _playbackSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Alarm frames timeline
          _buildAlarmFramesTimeline(),
          const SizedBox(height: 16),
          
          // Main playback controls
          _buildPlaybackControls(),
          const SizedBox(height: 12),
          
          // Frame scrubber
          _buildFrameScrubber(),
          const SizedBox(height: 12),
          
          // Additional controls
          _buildAdditionalControls(),
        ],
      ),
    );
  }

  Widget _buildAlarmFramesTimeline() {
    if (widget.alarmFrames.isEmpty) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No alarm frames detected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Alarm Frames (${widget.alarmFrames.length})',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Spacer(),
              Switch(
                value: _showAlarmFramesOnly,
                onChanged: (value) => setState(() => _showAlarmFramesOnly = value),
              ),
              const SizedBox(width: 8),
              Text(
                'Alarm Only',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.alarmFrames.length,
              itemBuilder: (context, index) {
                final frame = widget.alarmFrames[index];
                final isSelected = frame.frameNumber == widget.currentFrame;
                
                return GestureDetector(
                  onTap: () => widget.onFrameChanged?.call(frame.frameNumber),
                  child: Container(
                    width: 60,
                    height: 40,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : _getAlarmColor(frame.score),
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: isSelected 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : null,
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
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous frame
        IconButton(
          onPressed: widget.onPrevious,
          icon: const Icon(Icons.skip_previous),
          tooltip: 'Previous Frame',
        ),
        
        // Previous alarm frame
        IconButton(
          onPressed: _gotoPreviousAlarmFrame,
          icon: const Icon(Icons.fast_rewind),
          tooltip: 'Previous Alarm Frame',
        ),
        
        const SizedBox(width: 16),
        
        // Play/Pause
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: widget.isPlaying ? widget.onPause : widget.onPlay,
            icon: Icon(
              widget.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            iconSize: 32,
            tooltip: widget.isPlaying ? 'Pause' : 'Play',
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Next alarm frame
        IconButton(
          onPressed: _gotoNextAlarmFrame,
          icon: const Icon(Icons.fast_forward),
          tooltip: 'Next Alarm Frame',
        ),
        
        // Next frame
        IconButton(
          onPressed: widget.onNext,
          icon: const Icon(Icons.skip_next),
          tooltip: 'Next Frame',
        ),
      ],
    );
  }

  Widget _buildFrameScrubber() {
    final totalFrames = widget.event.frames ?? 100;
    
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Frame: ${widget.currentFrame}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const Spacer(),
            Text(
              'Total: $totalFrames',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: widget.currentFrame.toDouble(),
            min: 1,
            max: totalFrames.toDouble(),
            divisions: totalFrames - 1,
            onChanged: (value) => widget.onFrameChanged?.call(value.round()),
            label: 'Frame ${widget.currentFrame}',
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalControls() {
    return Row(
      children: [
        // Playback speed
        Text(
          'Speed:',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(width: 8),
        DropdownButton<double>(
          value: _playbackSpeed,
          onChanged: (speed) => setState(() => _playbackSpeed = speed!),
          items: const [
            DropdownMenuItem(value: 0.25, child: Text('0.25x')),
            DropdownMenuItem(value: 0.5, child: Text('0.5x')),
            DropdownMenuItem(value: 1.0, child: Text('1x')),
            DropdownMenuItem(value: 2.0, child: Text('2x')),
            DropdownMenuItem(value: 4.0, child: Text('4x')),
          ],
        ),
        
        const Spacer(),
        
        // Export options
        IconButton(
          onPressed: _showExportOptions,
          icon: const Icon(Icons.download),
          tooltip: 'Export Options',
        ),
        
        // Event info
        IconButton(
          onPressed: _showEventInfo,
          icon: const Icon(Icons.info_outline),
          tooltip: 'Event Information',
        ),
      ],
    );
  }

  Color _getAlarmColor(double score) {
    if (score >= 80) return Colors.red;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.yellow;
    return Colors.grey;
  }

  void _gotoPreviousAlarmFrame() {
    final currentIndex = widget.alarmFrames.indexWhere(
      (frame) => frame.frameNumber >= widget.currentFrame,
    );
    
    if (currentIndex > 0) {
      final previousFrame = widget.alarmFrames[currentIndex - 1];
      widget.onFrameChanged?.call(previousFrame.frameNumber);
    }
  }

  void _gotoNextAlarmFrame() {
    final currentIndex = widget.alarmFrames.indexWhere(
      (frame) => frame.frameNumber > widget.currentFrame,
    );
    
    if (currentIndex >= 0 && currentIndex < widget.alarmFrames.length) {
      final nextFrame = widget.alarmFrames[currentIndex];
      widget.onFrameChanged?.call(nextFrame.frameNumber);
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.gif),
              title: const Text('Export as GIF'),
              subtitle: const Text('Create animated GIF from event'),
              onTap: () {
                Navigator.pop(context);
                _exportAsGif();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_file),
              title: const Text('Download Video'),
              subtitle: const Text('Download original video file'),
              onTap: () {
                Navigator.pop(context);
                _downloadVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Export Frames'),
              subtitle: const Text('Download alarm frames as images'),
              onTap: () {
                Navigator.pop(context);
                _exportFrames();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEventInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Event Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Event ID', widget.event.id),
              _buildInfoRow('Monitor', widget.event.monitorName ?? 'Unknown'),
              _buildInfoRow('Start Time', widget.event.startTime.toString()),
              _buildInfoRow('Duration', '${widget.event.length}s'),
              _buildInfoRow('Frames', '${widget.event.frames ?? 0}'),
              _buildInfoRow('Alarm Frames', '${widget.event.alarmFrames ?? 0}'),
              _buildInfoRow('Max Score', '${widget.event.maxScore ?? 0}'),
              if (widget.event.notes?.isNotEmpty == true)
                _buildInfoRow('Notes', widget.event.notes!),
            ],
          ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _exportAsGif() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GIF export functionality coming soon')),
    );
  }

  void _downloadVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video download functionality coming soon')),
    );
  }

  void _exportFrames() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Frame export functionality coming soon')),
    );
  }
}
