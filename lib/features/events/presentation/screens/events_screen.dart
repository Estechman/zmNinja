import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/events_providers.dart';
import '../widgets/events_list_widget.dart';
import '../widgets/events_filter_widget.dart';
import '../widgets/timeline_view_widget.dart';

/// Events screen for browsing recorded events
/// Displays list of security events with filtering and timeline view
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('EventsScreen: build() called - widget is rendering');
    final events = ref.watch(eventsProvider);
    final viewMode = ref.watch(eventsViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: Icon(viewMode == EventsViewMode.list ? Icons.timeline : Icons.list),
            onPressed: () => ref.read(eventsViewModeProvider.notifier).toggle(),
            tooltip: viewMode == EventsViewMode.list ? 'Timeline View' : 'List View',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(eventsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          const EventsFilterWidget(),
          Expanded(
            child: events.when(
              data: (eventsList) {
                if (eventsList.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No events found'),
                      ],
                    ),
                  );
                }

                return viewMode == EventsViewMode.list
                    ? EventsListWidget(events: eventsList)
                    : TimelineViewWidget(events: eventsList);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading events: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(eventsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createManualEvent(context, ref),
        tooltip: 'Create Event',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Events'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter options coming soon...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _createManualEvent(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manual event creation coming soon...'),
      ),
    );
  }
}
