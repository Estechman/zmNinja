import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/event_model.dart';
import '../widgets/event_player_widget.dart';

class EventPlayerScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventPlayerScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<EventPlayerScreen> createState() => _EventPlayerScreenState();
}

class _EventPlayerScreenState extends ConsumerState<EventPlayerScreen> {
  bool _isFullscreen = false;
  late EventModel _mockEvent;

  @override
  void initState() {
    super.initState();
    _mockEvent = EventModel(
      id: widget.eventId,
      cameraId: '1',
      cameraName: 'Front Door',
      name: 'Motion Detection Event ${widget.eventId}',
      cause: 'Motion',
      notes: 'Person detected at front entrance',
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().subtract(const Duration(hours: 2, minutes: -3)),
      length: 180,
      frames: 5400,
      alarmFrames: 450,
      maxScore: 85.6,
      avgScore: 42.3,
      thumbnailPath: '/events/1/snapshot.jpg',
      videoPath: '/events/1/video.mp4',
      state: EventState.alarm,
      archived: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 840;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen ? null : AppBar(
        title: Text(_mockEvent.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: _toggleFullscreen,
            tooltip: 'Toggle Fullscreen',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'download',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Download Video'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'gif',
                child: ListTile(
                  leading: Icon(Icons.gif),
                  title: Text('Create GIF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  leading: Icon(Icons.archive),
                  title: Text('Archive'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isFullscreen
          ? EventPlayerWidget(event: _mockEvent)
          : isDesktop
              ? _buildDesktopLayout()
              : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: EventPlayerWidget(event: _mockEvent),
        ),
        Container(
          width: 300,
          color: Theme.of(context).colorScheme.surface,
          child: _buildEventMetadata(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: EventPlayerWidget(event: _mockEvent),
        ),
        Expanded(
          child: _buildEventMetadata(),
        ),
      ],
    );
  }

  Widget _buildEventMetadata() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          _buildMetadataRow('Camera', _mockEvent.cameraName),
          _buildMetadataRow('Start Time', _formatDateTime(_mockEvent.startTime)),
          _buildMetadataRow('Duration', _mockEvent.durationString),
          _buildMetadataRow('Frames', '${_mockEvent.frames}'),
          _buildMetadataRow('Alarm Frames', '${_mockEvent.alarmFrames}'),
          _buildMetadataRow('Max Score', _mockEvent.maxScore.toStringAsFixed(1)),
          _buildMetadataRow('Avg Score', _mockEvent.avgScore.toStringAsFixed(1)),
          
          if (_mockEvent.cause != null) ...[
            const SizedBox(height: 8),
            _buildMetadataRow('Cause', _mockEvent.cause!),
          ],
          
          if (_mockEvent.notes != null) ...[
            const SizedBox(height: 16),
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(_mockEvent.notes!),
          ],
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleMenuAction('download'),
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleMenuAction('gif'),
                  icon: const Icon(Icons.gif),
                  label: const Text('Create GIF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading video...')),
        );
        break;
      case 'gif':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creating GIF...')),
        );
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sharing event...')),
        );
        break;
      case 'archive':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archiving event...')),
        );
        break;
    }
  }
}
