import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/event_model.dart';
import 'event_card_widget.dart';

/// Widget for displaying events in a list format
/// Shows events as cards with thumbnail, details, and actions
class EventsListWidget extends ConsumerWidget {
  final List<EventModel> events;

  const EventsListWidget({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('EventsListWidget: Building with ${events.length} events');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        print('EventsListWidget: Building event card for event ${event.id}: ${event.name}');
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EventCardWidget(
            event: event,
            onTap: () => _showEventDetails(context, event),
            onPlay: () => _playEvent(context, event),
            onDownload: () => _downloadEvent(context, event),
          ),
        );
      },
    );
  }

  /// Show event details by navigating to EventDetailScreen
  void _showEventDetails(BuildContext context, EventModel event) {
    context.go('/event/${event.id}');
  }

  /// Play event video
  void _playEvent(BuildContext context, EventModel event) {
    // TODO: Implement event video playback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playing event: ${event.name}')),
    );
  }

  /// Download event
  void _downloadEvent(BuildContext context, EventModel event) {
    // TODO: Implement event download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading event: ${event.name}')),
    );
  }
}
