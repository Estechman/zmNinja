import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/alarm_frame_model.dart';
import 'timeline_range_widget.dart';
import 'event_thumbnail_widget.dart';

/// Interactive timeline widget with event visualization
/// Replicates original zmNinja's vis.js timeline functionality
class InteractiveTimelineWidget extends ConsumerStatefulWidget {
  final List<EventModel> events;
  final DateTimeRange? dateRange;
  final String? selectedMonitor;
  final Function(EventModel)? onEventSelected;

  const InteractiveTimelineWidget({
    super.key,
    required this.events,
    this.dateRange,
    this.selectedMonitor,
    this.onEventSelected,
  });

  @override
  ConsumerState<InteractiveTimelineWidget> createState() => _InteractiveTimelineWidgetState();
}

class _InteractiveTimelineWidgetState extends ConsumerState<InteractiveTimelineWidget> {
  DateTime _currentDate = DateTime.now();
  bool _showAlarmFramesOnly = false;
  EventModel? _selectedEvent;
  EventModel? _hoveredEvent;
  Offset? _hoverPosition;
  double _zoomLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTimelineControls(),
        Expanded(
          child: Stack(
            children: [
              TimelineRangeWidget(
                events: _getFilteredEvents(),
                dateRange: _getCurrentDateRange(),
                onEventSelected: _handleEventSelected,
                onEventHover: _handleEventHover,
                onEventDoubleClick: _handleEventDoubleClick,
              ),
              
              if (_hoveredEvent != null && _hoverPosition != null)
                EventThumbnailWidget(
                  event: _hoveredEvent!,
                  position: _hoverPosition!,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousDay,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Day',
          ),
          OutlinedButton.icon(
            onPressed: _showDatePicker,
            icon: const Icon(Icons.calendar_today),
            label: Text(_formatDate(_currentDate)),
          ),
          IconButton(
            onPressed: _nextDay,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Day',
          ),
          
          const SizedBox(width: 16),
          
          ElevatedButton.icon(
            onPressed: _gotoNow,
            icon: const Icon(Icons.access_time),
            label: const Text('Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          
          const SizedBox(width: 16),
          
          IconButton(
            onPressed: _zoomIn,
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
          ),
          IconButton(
            onPressed: _zoomOut,
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
          ),
          
          const SizedBox(width: 16),
          
          FilterChip(
            label: const Text('Alarm Frames Only'),
            selected: _showAlarmFramesOnly,
            onSelected: _toggleMinAlarmFrameCount,
          ),
          
          const Spacer(),
          
          IconButton(
            onPressed: _fitTimeline,
            icon: const Icon(Icons.fit_screen),
            tooltip: 'Fit Timeline',
          ),
        ],
      ),
    );
  }


  List<EventModel> _getFilteredEvents() {
    var events = widget.events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final currentDate = DateTime(
        _currentDate.year,
        _currentDate.month,
        _currentDate.day,
      );
      
      bool dateMatch = eventDate.isAtSameMomentAs(currentDate);
      bool monitorMatch = widget.selectedMonitor == null || 
                         event.monitorId == widget.selectedMonitor;
      bool alarmMatch = !_showAlarmFramesOnly || event.alarmFrames > 0;
      
      return dateMatch && monitorMatch && alarmMatch;
    }).toList();
    
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    return events;
  }

  DateTimeRange _getCurrentDateRange() {
    final startOfDay = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return DateTimeRange(start: startOfDay, end: endOfDay);
  }

  void _handleEventSelected(EventModel event) {
    setState(() {
      _selectedEvent = event;
    });
    widget.onEventSelected?.call(event);
  }

  void _handleEventHover(EventModel event, Offset position) {
    setState(() {
      _hoveredEvent = event;
      _hoverPosition = position;
    });
  }

  void _handleEventDoubleClick(EventModel event) {
    widget.onEventSelected?.call(event);
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _currentDate = date;
        _selectedEvent = null;
        _hoveredEvent = null;
      });
    }
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel * 1.5).clamp(0.5, 5.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel / 1.5).clamp(0.5, 5.0);
    });
  }

  void _previousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
      _selectedEvent = null;
      _hoveredEvent = null;
    });
  }

  void _nextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
      _selectedEvent = null;
      _hoveredEvent = null;
    });
  }

  void _gotoNow() {
    setState(() {
      _currentDate = DateTime.now();
      _selectedEvent = null;
      _hoveredEvent = null;
    });
  }

  void _toggleMinAlarmFrameCount(bool selected) {
    setState(() {
      _showAlarmFramesOnly = selected;
    });
  }

  void _fitTimeline() {
    setState(() {
      _zoomLevel = 1.0;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
