import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/event_model.dart';

/// Timeline range widget that displays events as horizontal bars grouped by monitor
/// Replicates original zmNinja's vis.js Timeline functionality
class TimelineRangeWidget extends ConsumerStatefulWidget {
  final List<EventModel> events;
  final DateTimeRange dateRange;
  final Function(EventModel)? onEventSelected;
  final Function(EventModel, Offset)? onEventHover;
  final Function(EventModel)? onEventDoubleClick;

  const TimelineRangeWidget({
    super.key,
    required this.events,
    required this.dateRange,
    this.onEventSelected,
    this.onEventHover,
    this.onEventDoubleClick,
  });

  @override
  ConsumerState<TimelineRangeWidget> createState() => _TimelineRangeWidgetState();
}

class _TimelineRangeWidgetState extends ConsumerState<TimelineRangeWidget> {
  final ScrollController _scrollController = ScrollController();
  EventModel? _hoveredEvent;
  EventModel? _selectedEvent;

  @override
  Widget build(BuildContext context) {
    final groupedEvents = _groupEventsByMonitor();
    final timelineWidth = _calculateTimelineWidth();
    
    return Column(
      children: [
        _buildTimelineHeader(),
        Expanded(
          child: Row(
            children: [
              _buildMonitorLabels(groupedEvents),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: timelineWidth,
                    child: _buildTimelineContent(groupedEvents),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, List<EventModel>> _groupEventsByMonitor() {
    final grouped = <String, List<EventModel>>{};
    for (final event in widget.events) {
      grouped.putIfAbsent(event.cameraId, () => []).add(event);
    }
    grouped.forEach((key, events) {
      events.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
    return grouped;
  }

  Widget _buildTimelineHeader() {
    return Container(
      height: 40,
      child: Row(
        children: [
          Container(width: 150, child: Text('Monitor', style: Theme.of(context).textTheme.labelMedium)),
          Expanded(child: _buildTimeScale()),
        ],
      ),
    );
  }

  Widget _buildTimeScale() {
    final intervals = _calculateTimeIntervals();
    
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: intervals.map((time) => Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _formatTimeLabel(time),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMonitorLabels(Map<String, List<EventModel>> groupedEvents) {
    return Container(
      width: 150,
      child: Column(
        children: groupedEvents.entries.map((entry) {
          final cameraName = entry.value.first.cameraName;
          return Container(
            height: 60,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                cameraName,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineContent(Map<String, List<EventModel>> groupedEvents) {
    return Column(
      children: groupedEvents.entries.map((entry) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: _buildMonitorTimeline(entry.value),
        );
      }).toList(),
    );
  }

  Widget _buildMonitorTimeline(List<EventModel> events) {
    return Stack(
      children: events.map((event) => _buildEventBar(event)).toList(),
    );
  }

  Widget _buildEventBar(EventModel event) {
    final startPosition = _calculateEventPosition(event.startTime);
    final width = _calculateEventWidth(event);
    final color = _getEventColor(event);
    
    return Positioned(
      left: startPosition,
      top: 10,
      child: GestureDetector(
        onTap: () => _handleEventTap(event),
        onDoubleTap: () => _handleEventDoubleTap(event),
        child: MouseRegion(
          onEnter: (details) => _handleEventHover(event, details.position),
          onExit: (_) => _handleEventHoverExit(),
          child: Container(
            width: width,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _selectedEvent?.id == event.id ? Colors.white : color.withOpacity(0.8),
                width: _selectedEvent?.id == event.id ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    size: 12,
                    color: Colors.white,
                  ),
                  SizedBox(width: 2),
                  Text(
                    '${event.alarmFrames}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (width > 60) ...[
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateTimelineWidth() {
    return MediaQuery.of(context).size.width * 2;
  }

  double _calculateEventPosition(DateTime eventTime) {
    final totalDuration = widget.dateRange.duration.inMilliseconds;
    final eventOffset = eventTime.difference(widget.dateRange.start).inMilliseconds;
    final timelineWidth = _calculateTimelineWidth();
    return (eventOffset / totalDuration) * timelineWidth;
  }

  double _calculateEventWidth(EventModel event) {
    final eventDuration = event.length * 1000;
    final totalDuration = widget.dateRange.duration.inMilliseconds;
    final timelineWidth = _calculateTimelineWidth();
    final width = (eventDuration / totalDuration) * timelineWidth;
    return width.clamp(20.0, timelineWidth);
  }

  Color _getEventColor(EventModel event) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    final colorIndex = int.tryParse(event.cameraId) ?? 0;
    return colors[colorIndex % colors.length];
  }

  List<DateTime> _calculateTimeIntervals() {
    final duration = widget.dateRange.duration;
    final intervals = <DateTime>[];
    
    if (duration.inDays > 1) {
      for (int i = 0; i <= duration.inHours; i += 6) {
        intervals.add(widget.dateRange.start.add(Duration(hours: i)));
      }
    } else {
      for (int i = 0; i <= 24; i += 2) {
        intervals.add(widget.dateRange.start.add(Duration(hours: i)));
      }
    }
    
    return intervals;
  }

  String _formatTimeLabel(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _handleEventTap(EventModel event) {
    setState(() {
      _selectedEvent = event;
    });
    widget.onEventSelected?.call(event);
  }

  void _handleEventDoubleTap(EventModel event) {
    widget.onEventDoubleClick?.call(event);
  }

  void _handleEventHover(EventModel event, Offset position) {
    setState(() {
      _hoveredEvent = event;
    });
    widget.onEventHover?.call(event, position);
  }

  void _handleEventHoverExit() {
    setState(() {
      _hoveredEvent = null;
    });
  }
}
