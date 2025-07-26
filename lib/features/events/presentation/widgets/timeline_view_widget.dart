import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/event_model.dart';

/// Widget for displaying events in a timeline format
/// Shows chronological view of events with time markers
class TimelineViewWidget extends ConsumerWidget {
  final List<EventModel> events;

  const TimelineViewWidget({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group events by date
    final groupedEvents = _groupEventsByDate(events);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedEvents.length,
      itemBuilder: (context, index) {
        final dateEntry = groupedEvents.entries.elementAt(index);
        final date = dateEntry.key;
        final dayEvents = dateEntry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _formatDate(date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),

            // Events for this date
            ...dayEvents.map((event) => _buildTimelineEvent(context, event)),
          ],
        );
      },
    );
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
              if (event != events.last)
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
