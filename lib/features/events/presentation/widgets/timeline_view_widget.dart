import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/event_model.dart';

/// Enhanced timeline widget with interactive charts
/// Replicates original zmNinja's vis.js timeline functionality
class TimelineViewWidget extends ConsumerStatefulWidget {
  final List<EventModel> events;
  final DateTimeRange? dateRange;

  const TimelineViewWidget({
    super.key,
    required this.events,
    this.dateRange,
  });

  @override
  ConsumerState<TimelineViewWidget> createState() => _TimelineViewWidgetState();
}

class _TimelineViewWidgetState extends ConsumerState<TimelineViewWidget> {
  DateTime _currentDate = DateTime.now();
  bool _showAlarmFramesOnly = false;
  String? _selectedMonitor;
  EventModel? _selectedEvent;

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _filterEvents();
    
    return Column(
      children: [
        _buildTimelineControls(),
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 3, child: _buildTimelineChart(filteredEvents)),
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
    final monitors = widget.events.map((e) => e.cameraName).toSet().toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Text(
            'Timeline View',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          
          DropdownButton<String>(
            value: _selectedMonitor,
            hint: const Text('All Monitors'),
            onChanged: (value) {
              setState(() {
                _selectedMonitor = value;
              });
            },
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Monitors'),
              ),
              ...monitors.map((monitor) => DropdownMenuItem<String>(
                value: monitor,
                child: Text(monitor),
              )),
            ],
          ),
          
          const SizedBox(width: 16),
          
          FilterChip(
            label: const Text('Alarm Frames Only'),
            selected: _showAlarmFramesOnly,
            onSelected: (selected) {
              setState(() {
                _showAlarmFramesOnly = selected;
              });
            },
          ),
          
          const SizedBox(width: 16),
          
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
            tooltip: 'Select Date',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineChart(List<EventModel> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text('No events found for selected criteria'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: _buildTitlesData(),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!),
          ),
          lineBarsData: _buildTimelineData(events),
          lineTouchData: LineTouchData(
            touchCallback: _handleTimelineTouch,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: _getTooltipItems,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
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
            _buildEventInfo(_selectedEvent!),
          ] else ...[
            const Text('Select an event on the timeline to view details'),
          ],
        ],
      ),
    );
  }

  Widget _buildEventInfo(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.name,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        
        _buildDetailRow('Camera', event.cameraName),
        _buildDetailRow('Start Time', _formatDateTime(event.startTime)),
        _buildDetailRow('Duration', event.durationString),
        _buildDetailRow('Max Score', event.maxScore.toStringAsFixed(1)),
        _buildDetailRow('Alarm Frames', '${event.alarmFrames}'),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.go('/event/${event.id}/player'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/event/${event.id}'),
                icon: const Icon(Icons.info),
                label: const Text('Details'),
              ),
            ),
          ],
        ),
      ],
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

  List<EventModel> _filterEvents() {
    var filtered = widget.events;
    
    if (_selectedMonitor != null) {
      filtered = filtered.where((e) => e.cameraName == _selectedMonitor).toList();
    }
    
    if (_showAlarmFramesOnly) {
      filtered = filtered.where((e) => e.alarmFrames > 0).toList();
    }
    
    return filtered;
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final hour = value.toInt();
            if (hour >= 0 && hour <= 23) {
              return Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: const TextStyle(fontSize: 10),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 20,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 10),
            );
          },
          reservedSize: 42,
        ),
      ),
    );
  }

  List<LineChartBarData> _buildTimelineData(List<EventModel> events) {
    final eventsByHour = <int, List<EventModel>>{};
    
    for (final event in events) {
      final hour = event.startTime.hour;
      eventsByHour.putIfAbsent(hour, () => []).add(event);
    }
    
    final spots = <FlSpot>[];
    for (int hour = 0; hour < 24; hour++) {
      final eventsInHour = eventsByHour[hour] ?? [];
      final maxScore = eventsInHour.isEmpty 
          ? 0.0 
          : eventsInHour.map((e) => e.maxScore).reduce((a, b) => a > b ? a : b);
      spots.add(FlSpot(hour.toDouble(), maxScore));
    }
    
    return [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: Colors.blue,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: Colors.blue,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
    ];
  }

  void _handleTimelineTouch(FlTouchEvent event, LineTouchResponse? touchResponse) {
    if (touchResponse != null && touchResponse.lineBarSpots != null) {
      final spot = touchResponse.lineBarSpots!.first;
      final hour = spot.x.toInt();
      
      final eventsInHour = widget.events.where((e) => e.startTime.hour == hour).toList();
      if (eventsInHour.isNotEmpty) {
        setState(() {
          _selectedEvent = eventsInHour.first;
        });
      }
    }
  }

  List<LineTooltipItem> _getTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((LineBarSpot touchedSpot) {
      final hour = touchedSpot.x.toInt();
      final score = touchedSpot.y;
      return LineTooltipItem(
        'Hour: ${hour.toString().padLeft(2, '0')}:00\nMax Score: ${score.toStringAsFixed(1)}',
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _currentDate = picked;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Group events by date
  Map<DateTime, List<EventModel>> _groupEventsByDate(List<EventModel> events) {
    final grouped = <DateTime, List<EventModel>>{};
    
    for (final event in events) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      
      grouped.putIfAbsent(date, () => []).add(event);
    }
    
    // Sort by date (newest first)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    
    return Map.fromEntries(sortedEntries);
  }

  /// Build individual timeline event
  Widget _buildTimelineEvent(BuildContext context, EventModel event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time marker
          Column(
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  _formatTime(event.startTime),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getEventColor(event),
                  shape: BoxShape.circle,
                ),
              ),
              if (event != widget.events.last)
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey[300],
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Event content
          Expanded(
            child: Card(
              child: InkWell(
                onTap: () => _showEventDetails(context, event),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.name,
                              style: Theme.of(context).textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            event.cameraName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Event details
                      Row(
                        children: [
                          Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            event.durationString,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          if (event.alarmFrames > 0) ...[
                            Icon(Icons.warning, size: 14, color: Colors.orange[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Score: ${event.maxScore.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[600],
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (event.cause != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Cause: ${event.cause}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get event color based on alarm score
  Color _getEventColor(EventModel event) {
    if (event.maxScore >= 80) return Colors.red;
    if (event.maxScore >= 60) return Colors.orange;
    if (event.maxScore >= 40) return Colors.yellow[700]!;
    return Colors.green;
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Format time for display
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }

  /// Show event details
  void _showEventDetails(BuildContext context, EventModel event) {
    // TODO: Navigate to event detail screen or show modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event details: ${event.name}')),
    );
  }
}
