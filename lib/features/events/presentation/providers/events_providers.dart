import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/event_model.dart';
import '../../../../core/services/zm_api_service.dart';
import '../../../../core/services/local_storage_service.dart';

/// Events filters data class
class EventsFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? cameraId;
  final EventType? eventType;
  final double? minAlarmScore;

  const EventsFilters({
    this.startDate,
    this.endDate,
    this.cameraId,
    this.eventType,
    this.minAlarmScore,
  });

  /// Create copy with updated filters
  EventsFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? cameraId,
    EventType? eventType,
    double? minAlarmScore,
  }) {
    return EventsFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cameraId: cameraId ?? this.cameraId,
      eventType: eventType ?? this.eventType,
      minAlarmScore: minAlarmScore ?? this.minAlarmScore,
    );
  }
}

/// Provider for events search query
final eventsSearchProvider = StateProvider<String>((ref) => '');

/// Provider for events list from ZoneMinder API
/// Fetches and manages list of recorded events
final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final apiService = ref.watch(zmApiServiceProvider);
  final storageService = ref.watch(localStorageServiceProvider);
  final filters = ref.watch(eventsFiltersProvider);
  
  try {
    // Try to get events from ZoneMinder API
    final events = await apiService.getEvents(filters: filters);
    
    // Cache the events for offline use
    await storageService.cacheEvents(events);
    
    return events;
  } catch (e) {
    // Try to get cached events first
    try {
      final cachedEvents = await storageService.getCachedEvents();
      if (cachedEvents.isNotEmpty) {
        return cachedEvents;
      }
    } catch (cacheError) {
      // Cache also failed, continue to mock data
    }
    
    // Fallback to mock data if API and cache are not available
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();
    final mockEvents = [
      EventModel(
        id: '1',
        cameraId: '1',
        cameraName: 'Front Door',
        name: 'Motion Detection',
        cause: 'Motion',
        notes: 'Person detected at front entrance',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 2, minutes: -3)),
        length: 180,
        frames: 5400,
        alarmFrames: 450,
        maxScore: 85.6,
        avgScore: 42.3,
        thumbnailPath: '/events/1/snapshot.jpg',
        videoPath: '/events/1/video.mp4',
        state: EventState.alarm,
        archived: false,
      ),
      EventModel(
        id: '2',
        cameraId: '2',
        cameraName: 'Backyard',
        name: 'Zone Intrusion',
        cause: 'Zone',
        notes: 'Movement detected in restricted area',
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 4, minutes: -1)),
        length: 65,
        frames: 1950,
        alarmFrames: 120,
        maxScore: 72.4,
        avgScore: 38.9,
        thumbnailPath: '/events/2/snapshot.jpg',
        videoPath: '/events/2/video.mp4',
        state: EventState.alert,
        archived: false,
      ),
      EventModel(
        id: '3',
        cameraId: '4',
        cameraName: 'Driveway',
        name: 'Vehicle Detection',
        cause: 'Motion',
        notes: 'Car entering driveway',
        startTime: now.subtract(const Duration(hours: 6)),
        endTime: now.subtract(const Duration(hours: 6, minutes: -2)),
        length: 120,
        frames: 3600,
        alarmFrames: 280,
        maxScore: 91.2,
        avgScore: 55.7,
        thumbnailPath: '/events/3/snapshot.jpg',
        videoPath: '/events/3/video.mp4',
        state: EventState.alarm,
        archived: true,
      ),
      EventModel(
        id: '4',
        cameraId: '1',
        cameraName: 'Front Door',
        name: 'Package Delivery',
        cause: 'Motion',
        notes: 'Delivery person at door',
        startTime: now.subtract(const Duration(days: 1, hours: 2)),
        endTime: now.subtract(const Duration(days: 1, hours: 2, minutes: -4)),
        length: 240,
        frames: 7200,
        alarmFrames: 380,
        maxScore: 78.9,
        avgScore: 45.2,
        thumbnailPath: '/events/4/snapshot.jpg',
        videoPath: '/events/4/video.mp4',
        state: EventState.alarm,
        archived: false,
      ),
      EventModel(
        id: '5',
        cameraId: '3',
        cameraName: 'Living Room',
        name: 'Motion Alert',
        cause: 'Motion',
        notes: 'Pet movement detected',
        startTime: now.subtract(const Duration(days: 1, hours: 8)),
        endTime: now.subtract(const Duration(days: 1, hours: 8, minutes: -1)),
        length: 45,
        frames: 1350,
        alarmFrames: 85,
        maxScore: 34.5,
        avgScore: 22.1,
        thumbnailPath: '/events/5/snapshot.jpg',
        videoPath: '/events/5/video.mp4',
        state: EventState.idle,
        archived: false,
      ),
      EventModel(
        id: '6',
        cameraId: '2',
        cameraName: 'Backyard',
        name: 'Night Motion',
        cause: 'Motion',
        notes: 'Nocturnal animal activity',
        startTime: now.subtract(const Duration(days: 2, hours: 3)),
        endTime: now.subtract(const Duration(days: 2, hours: 3, minutes: -2)),
        length: 95,
        frames: 2850,
        alarmFrames: 145,
        maxScore: 56.8,
        avgScore: 31.4,
        thumbnailPath: '/events/6/snapshot.jpg',
        videoPath: '/events/6/video.mp4',
        state: EventState.alert,
        archived: false,
      ),
    ];
    
    return mockEvents;
  }
});

/// Provider for events view mode (list vs timeline)
/// Manages how events are displayed
final eventsViewModeProvider = StateNotifierProvider<EventsViewModeNotifier, EventsViewMode>((ref) {
  return EventsViewModeNotifier();
});

/// Provider for events loading state
/// Tracks if events are currently being loaded
final eventsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(eventsProvider).isLoading;
});

/// Provider for events filters
/// Manages filtering criteria for events
final eventsFiltersProvider = StateProvider<EventsFilters>((ref) {
  return const EventsFilters();
});

/// Provider for selected event
/// Manages currently selected event for detail view
final selectedEventProvider = StateProvider<EventModel?>((ref) {
  return null;
});

/// Notifier for events view mode management
class EventsViewModeNotifier extends StateNotifier<EventsViewMode> {
  EventsViewModeNotifier() : super(EventsViewMode.list);

  /// Toggle between list and timeline view
  void toggle() {
    state = state == EventsViewMode.list 
        ? EventsViewMode.timeline 
        : EventsViewMode.list;
  }

  /// Set specific view mode
  void setViewMode(EventsViewMode mode) {
    state = mode;
  }
}

/// Enum for events view modes
enum EventsViewMode {
  list,     // List view with event cards
  timeline, // Timeline view with chronological display
}

/// Event type enum
enum EventType {
  motion,
  alarm,
  manual,
}
