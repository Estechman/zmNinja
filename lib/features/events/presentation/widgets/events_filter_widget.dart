import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/events_providers.dart';

/// Widget for filtering events by various criteria
/// Displays filter chips and search functionality
class EventsFilterWidget extends ConsumerWidget {
  const EventsFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(eventsFiltersProvider);
    // final searchQuery = ref.watch(eventsSearchProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search events...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) => ref.read(eventsSearchProvider.notifier).state = value,
          ),

          const SizedBox(height: 12),

          // Filter chips
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              // Date filter chip
              FilterChip(
                label: Text(filters.startDate != null 
                    ? 'Date: ${_formatDate(filters.startDate!)}'
                    : 'All Dates'),
                selected: filters.startDate != null,
                onSelected: (selected) => _showDatePicker(context, ref),
              ),

              // Camera filter chip
              FilterChip(
                label: Text(filters.cameraId != null 
                    ? 'Camera: ${filters.cameraId}'
                    : 'All Cameras'),
                selected: filters.cameraId != null,
                onSelected: (selected) => _showCameraPicker(context, ref),
              ),

              // Event type filter chip
              FilterChip(
                label: Text(filters.eventType != null 
                    ? 'Type: ${filters.eventType!.name}'
                    : 'All Types'),
                selected: filters.eventType != null,
                onSelected: (selected) => _showEventTypePicker(context, ref),
              ),

              // Alarm score filter chip
              FilterChip(
                label: Text(filters.minAlarmScore != null 
                    ? 'Score: ≥${filters.minAlarmScore!.toStringAsFixed(0)}'
                    : 'Any Score'),
                selected: filters.minAlarmScore != null,
                onSelected: (selected) => _showScorePicker(context, ref),
              ),

              // Clear filters chip
              if (_hasActiveFilters(filters))
                ActionChip(
                  label: const Text('Clear All'),
                  onPressed: () => _clearFilters(ref),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Check if any filters are active
  bool _hasActiveFilters(EventsFilters filters) {
    return filters.startDate != null ||
           filters.cameraId != null ||
           filters.eventType != null ||
           filters.minAlarmScore != null;
  }

  /// Clear all filters
  void _clearFilters(WidgetRef ref) {
    ref.read(eventsFiltersProvider.notifier).state = const EventsFilters();
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Show date picker dialog
  void _showDatePicker(BuildContext context, WidgetRef ref) async {
    final currentFilters = ref.read(eventsFiltersProvider);
    
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: currentFilters.startDate != null
          ? DateTimeRange(
              start: currentFilters.startDate!,
              end: currentFilters.endDate ?? DateTime.now(),
            )
          : null,
    );

    if (dateRange != null) {
      ref.read(eventsFiltersProvider.notifier).state = currentFilters.copyWith(
        startDate: dateRange.start,
        endDate: dateRange.end,
      );
    }
  }

  /// Show camera picker dialog
  void _showCameraPicker(BuildContext context, WidgetRef ref) {
    // TODO: Implement camera picker with available cameras
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Camera'),
        content: const Text('Camera selection coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show event type picker dialog
  void _showEventTypePicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Event Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: EventType.values.map((type) {
            return ListTile(
              title: Text(type.name),
              onTap: () {
                Navigator.pop(context);
                final currentFilters = ref.read(eventsFiltersProvider);
                ref.read(eventsFiltersProvider.notifier).state = 
                    currentFilters.copyWith(eventType: type);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show alarm score picker dialog
  void _showScorePicker(BuildContext context, WidgetRef ref) {
    double currentScore = ref.read(eventsFiltersProvider).minAlarmScore ?? 0.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minimum Alarm Score'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score: ${currentScore.toStringAsFixed(0)}'),
              Slider(
                value: currentScore,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (value) => setState(() => currentScore = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final currentFilters = ref.read(eventsFiltersProvider);
              ref.read(eventsFiltersProvider.notifier).state = 
                  currentFilters.copyWith(minAlarmScore: currentScore);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
