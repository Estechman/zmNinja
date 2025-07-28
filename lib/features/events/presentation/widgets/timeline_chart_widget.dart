import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/models/event_model.dart';

/// Interactive timeline chart widget for event visualization
/// Replicates original zmNinja's vis.js timeline functionality
class TimelineChartWidget extends ConsumerStatefulWidget {
  final List<EventModel> events;
  final DateTimeRange dateRange;
  final Function(EventModel)? onEventSelected;

  const TimelineChartWidget({
    super.key,
    required this.events,
    required this.dateRange,
    this.onEventSelected,
  });

  @override
  ConsumerState<TimelineChartWidget> createState() => _TimelineChartWidgetState();
}

class _TimelineChartWidgetState extends ConsumerState<TimelineChartWidget> {
  EventModel? _selectedEvent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            verticalInterval: _getTimeInterval(),
            horizontalInterval: 1,
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _getTimeInterval(),
                getTitlesWidget: _buildBottomTitles,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: _buildLeftTitles,
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d)),
          ),
          minX: widget.dateRange.start.millisecondsSinceEpoch.toDouble(),
          maxX: widget.dateRange.end.millisecondsSinceEpoch.toDouble(),
          minY: 0,
          maxY: _getMaxCameraId().toDouble(),
          lineBarsData: _buildEventBars(),
          lineTouchData: LineTouchData(
            touchCallback: _handleTouch,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: _getTooltipItems,
            ),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildEventBars() {
    final Map<String, List<EventModel>> eventsByCamera = {};
    
    for (final event in widget.events) {
      eventsByCamera.putIfAbsent(event.cameraId, () => []).add(event);
    }

    return eventsByCamera.entries.map((entry) {
      final cameraId = entry.key;
      final events = entry.value;
      final cameraIndex = _getCameraIndex(cameraId);

      return LineChartBarData(
        spots: events.map((event) {
          return FlSpot(
            event.startTime.millisecondsSinceEpoch.toDouble(),
            cameraIndex.toDouble(),
          );
        }).toList(),
        isCurved: false,
        color: _getEventColor(events.first),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            final event = events[index];
            return FlDotCirclePainter(
              radius: _getEventRadius(event),
              color: _getEventColor(event),
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();
  }

  double _getTimeInterval() {
    final duration = widget.dateRange.duration;
    if (duration.inDays > 7) {
      return Duration.millisecondsPerDay.toDouble();
    } else if (duration.inDays > 1) {
      return Duration.millisecondsPerHour.toDouble() * 6;
    } else {
      return Duration.millisecondsPerHour.toDouble();
    }
  }

  int _getMaxCameraId() {
    final cameraIds = widget.events.map((e) => _getCameraIndex(e.cameraId)).toSet();
    return cameraIds.isEmpty ? 1 : cameraIds.reduce((a, b) => a > b ? a : b) + 1;
  }

  int _getCameraIndex(String cameraId) {
    final uniqueCameraIds = widget.events.map((e) => e.cameraId).toSet().toList();
    uniqueCameraIds.sort();
    return uniqueCameraIds.indexOf(cameraId);
  }

  Color _getEventColor(EventModel event) {
    if (event.cause?.toLowerCase().contains('alarm') == true) {
      return Colors.red;
    } else if (event.cause?.toLowerCase().contains('motion') == true) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  double _getEventRadius(EventModel event) {
    if (event.cause?.toLowerCase().contains('alarm') == true) {
      return 6.0;
    } else {
      return 4.0;
    }
  }

  Widget _buildBottomTitles(double value, TitleMeta meta) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    final duration = widget.dateRange.duration;
    
    String text;
    if (duration.inDays > 7) {
      text = '${date.month}/${date.day}';
    } else if (duration.inDays > 1) {
      text = '${date.hour}:00';
    } else {
      text = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLeftTitles(double value, TitleMeta meta) {
    final cameraIndex = value.toInt();
    final uniqueCameraIds = widget.events.map((e) => e.cameraId).toSet().toList();
    uniqueCameraIds.sort();
    
    if (cameraIndex < uniqueCameraIds.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          'Cam ${uniqueCameraIds[cameraIndex]}',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  void _handleTouch(FlTouchEvent event, LineTouchResponse? touchResponse) {
    if (touchResponse?.lineBarSpots != null && touchResponse!.lineBarSpots!.isNotEmpty) {
      final spot = touchResponse.lineBarSpots!.first;
      final timestamp = spot.x.toInt();
      final cameraIndex = spot.y.toInt();
      
      // Find the event closest to this timestamp and camera
      final event = _findEventAtPosition(timestamp, cameraIndex);
      if (event != null) {
        setState(() {
          _selectedEvent = event;
        });
        widget.onEventSelected?.call(event);
      }
    }
  }

  EventModel? _findEventAtPosition(int timestamp, int cameraIndex) {
    final uniqueCameraIds = widget.events.map((e) => e.cameraId).toSet().toList();
    uniqueCameraIds.sort();
    
    if (cameraIndex >= uniqueCameraIds.length) return null;
    
    final cameraId = uniqueCameraIds[cameraIndex];
    final cameraEvents = widget.events.where((e) => e.cameraId == cameraId).toList();
    
    EventModel? closestEvent;
    int minDifference = double.maxFinite.toInt();
    
    for (final event in cameraEvents) {
      final difference = (event.startTime.millisecondsSinceEpoch - timestamp).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestEvent = event;
      }
    }
    
    return closestEvent;
  }

  List<LineTooltipItem> _getTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((LineBarSpot touchedSpot) {
      final event = _findEventAtPosition(
        touchedSpot.x.toInt(),
        touchedSpot.y.toInt(),
      );
      
      if (event != null) {
        return LineTooltipItem(
          '${event.name}\n${event.startTime.toString().split('.')[0]}\nCause: ${event.cause ?? 'Unknown'}',
          const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      }
      
      return LineTooltipItem(
        'Event',
        const TextStyle(color: Colors.white),
      );
    }).toList();
  }
}
