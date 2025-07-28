import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/alarm_frame_model.dart';

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
  double _zoomLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTimelineControls(),
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 3, child: _buildTimelineChart()),
              Container(
                width: 300,
                child: _buildEventDetails(),
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
          // Date picker
          OutlinedButton.icon(
            onPressed: _showDatePicker,
            icon: const Icon(Icons.calendar_today),
            label: Text(_formatDate(_currentDate)),
          ),
          const SizedBox(width: 16),
          
          // Zoom controls
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
          
          // Filter toggle
          FilterChip(
            label: const Text('Alarm Frames Only'),
            selected: _showAlarmFramesOnly,
            onSelected: (selected) {
              setState(() {
                _showAlarmFramesOnly = selected;
              });
            },
          ),
          
          const Spacer(),
          
          // Navigation buttons
          IconButton(
            onPressed: _previousDay,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Day',
          ),
          IconButton(
            onPressed: _nextDay,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Day',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineChart() {
    final filteredEvents = _getFilteredEvents();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            verticalInterval: _getTimeInterval(),
            getDrawingVerticalLine: (value) => FlLine(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: _buildTitlesData(),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          lineBarsData: _buildTimelineData(filteredEvents),
          lineTouchData: LineTouchData(
            enabled: true,
            touchCallback: _handleTimelineTouch,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItems: _getTooltipItems,
            ),
          ),
          minX: 0,
          maxX: 24,
          minY: 0,
          maxY: _getMaxEventCount(),
        ),
      ),
    );
  }

  Widget _buildEventDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Details',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          if (_selectedEvent != null) ...[
            _buildEventDetailCard(_selectedEvent!),
          ] else ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Click on timeline to view event details',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventDetailCard(EventModel event) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getEventIcon(event),
                  color: _getEventColor(event),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            _buildDetailRow('Monitor', event.monitorName ?? 'Unknown'),
            _buildDetailRow('Start Time', _formatDateTime(event.startTime)),
            _buildDetailRow('Duration', _formatDuration(event.length)),
            _buildDetailRow('Frames', '${event.frames}'),
            _buildDetailRow('Alarm Frames', '${event.alarmFrames}'),
            _buildDetailRow('Score', '${event.maxScore}'),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _playEvent(event),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadEvent(event),
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
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

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: Theme.of(context).textTheme.bodySmall,
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 2,
          getTitlesWidget: (value, meta) {
            final hour = value.toInt();
            return Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: Theme.of(context).textTheme.bodySmall,
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<LineChartBarData> _buildTimelineData(List<EventModel> events) {
    final hourlyEventCounts = <int, int>{};
    final hourlyAlarmCounts = <int, int>{};
    
    for (final event in events) {
      final hour = event.startTime.hour;
      hourlyEventCounts[hour] = (hourlyEventCounts[hour] ?? 0) + 1;
      if (event.alarmFrames > 0) {
        hourlyAlarmCounts[hour] = (hourlyAlarmCounts[hour] ?? 0) + 1;
      }
    }
    
    final eventSpots = <FlSpot>[];
    final alarmSpots = <FlSpot>[];
    
    for (int hour = 0; hour < 24; hour++) {
      eventSpots.add(FlSpot(hour.toDouble(), (hourlyEventCounts[hour] ?? 0).toDouble()));
      alarmSpots.add(FlSpot(hour.toDouble(), (hourlyAlarmCounts[hour] ?? 0).toDouble()));
    }
    
    return [
      LineChartBarData(
        spots: eventSpots,
        isCurved: true,
        color: Theme.of(context).colorScheme.primary,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 3,
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 1,
              strokeColor: Theme.of(context).colorScheme.surface,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      LineChartBarData(
        spots: alarmSpots,
        isCurved: true,
        color: Theme.of(context).colorScheme.error,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 3,
              color: Theme.of(context).colorScheme.error,
              strokeWidth: 1,
              strokeColor: Theme.of(context).colorScheme.surface,
            );
          },
        ),
      ),
    ];
  }

  void _handleTimelineTouch(FlTouchEvent event, LineTouchResponse? response) {
    if (response?.lineBarSpots?.isNotEmpty == true) {
      final spot = response!.lineBarSpots!.first;
      final hour = spot.x.toInt();
      
      final eventsAtHour = _getFilteredEvents().where((event) {
        return event.startTime.hour == hour;
      }).toList();
      
      if (eventsAtHour.isNotEmpty) {
        setState(() {
          _selectedEvent = eventsAtHour.first;
        });
        
        if (widget.onEventSelected != null) {
          widget.onEventSelected!(eventsAtHour.first);
        }
      }
    }
  }

  List<LineTooltipItem> _getTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((spot) {
      final hour = spot.x.toInt();
      final count = spot.y.toInt();
      final isAlarmData = spot.barIndex == 1;
      
      return LineTooltipItem(
        '${hour.toString().padLeft(2, '0')}:00\n${isAlarmData ? 'Alarms' : 'Events'}: $count',
        TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  double _getTimeInterval() {
    return 2.0 / _zoomLevel;
  }

  double _getMaxEventCount() {
    final events = _getFilteredEvents();
    final hourlyEventCounts = <int, int>{};
    
    for (final event in events) {
      final hour = event.startTime.hour;
      hourlyEventCounts[hour] = (hourlyEventCounts[hour] ?? 0) + 1;
    }
    
    final maxCount = hourlyEventCounts.values.isEmpty ? 10 : hourlyEventCounts.values.reduce((a, b) => a > b ? a : b);
    return (maxCount + 2).toDouble();
  }

  IconData _getEventIcon(EventModel event) {
    if (event.alarmFrames > 0) return Icons.warning;
    return Icons.videocam;
  }

  Color _getEventColor(EventModel event) {
    if (event.alarmFrames > 0) return Theme.of(context).colorScheme.error;
    return Theme.of(context).colorScheme.primary;
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
    });
  }

  void _nextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
      _selectedEvent = null;
    });
  }

  void _playEvent(EventModel event) {
    if (widget.onEventSelected != null) {
      widget.onEventSelected!(event);
    }
  }

  void _downloadEvent(EventModel event) {
    // TODO: Implement event download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading event ${event.name}...'),
        action: SnackBarAction(
          label: 'Cancel',
          onPressed: () {},
        ),
      ),
    );
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
