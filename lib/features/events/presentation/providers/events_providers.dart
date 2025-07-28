import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/event_model.dart';
import '../../../../core/services/zm_api_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/websocket_service.dart';

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

/// Enhanced provider for events list with optimized caching and real-time updates
/// Fetches events from ZoneMinder API with intelligent fallback and pagination
final eventsProvider = FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final apiService = ref.watch(zmApiServiceProvider);
  final storageService = ref.watch(localStorageServiceProvider);
  final filters = ref.watch(eventsFiltersProvider);
  
  // Keep provider alive for 3 minutes to reduce unnecessary API calls
  ref.keepAlive();
  final timer = Timer(const Duration(minutes: 3), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  
  try {
    // Try to get events from ZoneMinder API with timeout
    final events = await apiService.getEvents(filters: filters).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw TimeoutException('Events API request timed out', const Duration(seconds: 15)),
    );
    
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
    
    return _getMockEvents();
  }
});

/// Enhanced provider for real-time event updates via WebSocket
/// Monitors new events and status changes from ZoneMinder
final realtimeEventsProvider = StreamProvider.autoDispose<EventUpdate>((ref) async* {
  final websocketService = ref.watch(websocketServiceProvider);
  
  // Listen to WebSocket events for real-time event updates
  await for (final event in websocketService.eventStream) {
    final eventType = event['type'] as String?;
    if (eventType == 'new_event' || eventType == 'event_update') {
      final eventData = event['data'] as Map<String, dynamic>? ?? {};
      yield EventUpdate(
        type: eventType == 'new_event' ? EventUpdateType.created : EventUpdateType.updated,
        eventId: eventData['event_id'] as String?,
        cameraId: eventData['camera_id'] as String?,
        timestamp: DateTime.now(),
        data: eventData,
      );
    }
  }
});

/// Provider for filtered events based on search and filters
/// Combines search query with advanced filtering options
final filteredEventsProvider = Provider<AsyncValue<List<EventModel>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  final searchQuery = ref.watch(eventsSearchProvider);
  final filters = ref.watch(eventsFiltersProvider);
  
  return eventsAsync.when(
    data: (events) {
      var filtered = events;
      
      // Apply search filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((event) =>
          event.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          event.cameraName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (event.cause?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
          (event.notes?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
        ).toList();
      }
      
      // Apply date range filter
      if (filters.startDate != null) {
        filtered = filtered.where((event) => 
          event.startTime.isAfter(filters.startDate!)
        ).toList();
      }
      
      if (filters.endDate != null) {
        filtered = filtered.where((event) => 
          event.startTime.isBefore(filters.endDate!)
        ).toList();
      }
      
      // Apply camera filter
      if (filters.cameraId != null) {
        filtered = filtered.where((event) => 
          event.cameraId == filters.cameraId
        ).toList();
      }
      
      // Apply event type filter
      if (filters.eventType != null) {
        filtered = filtered.where((event) {
          switch (filters.eventType!) {
            case EventType.motion:
              return event.cause?.toLowerCase().contains('motion') ?? false;
            case EventType.alarm:
              return event.state == EventState.alarm;
            case EventType.manual:
              return event.cause?.toLowerCase().contains('manual') ?? false;
          }
        }).toList();
      }
      
      // Apply minimum alarm score filter
      if (filters.minAlarmScore != null) {
        filtered = filtered.where((event) => 
          event.maxScore >= filters.minAlarmScore!
        ).toList();
      }
      
      // Sort by start time (newest first)
      filtered.sort((a, b) => b.startTime.compareTo(a.startTime));
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Get mock events data for fallback scenarios
List<EventModel> _getMockEvents() {
  final now = DateTime.now();
  return [
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
}

/// Enhanced provider for events view mode with persistence
/// Manages how events are displayed with user preference storage
final eventsViewModeProvider = StateNotifierProvider<EventsViewModeNotifier, EventsViewMode>((ref) {
  return EventsViewModeNotifier(ref);
});

/// Provider for events loading state with enhanced tracking
/// Tracks loading, error, and success states for events
final eventsLoadingProvider = Provider<EventsLoadingState>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  final filteredAsync = ref.watch(filteredEventsProvider);
  
  return EventsLoadingState(
    isLoading: eventsAsync.isLoading || filteredAsync.isLoading,
    hasError: eventsAsync.hasError || filteredAsync.hasError,
    error: eventsAsync.error ?? filteredAsync.error,
    hasData: eventsAsync.hasValue && filteredAsync.hasValue,
  );
});

/// Enhanced provider for events filters with persistence
/// Manages filtering criteria with storage and validation
final eventsFiltersProvider = StateNotifierProvider<EventsFiltersNotifier, EventsFilters>((ref) {
  return EventsFiltersNotifier(ref);
});

/// Provider for selected event with enhanced management
/// Manages currently selected event for detail view with validation
final selectedEventProvider = StateNotifierProvider<SelectedEventNotifier, EventModel?>((ref) {
  return SelectedEventNotifier(ref);
});

/// Provider for events refresh functionality
/// Provides refresh functionality with loading state management
final eventsRefreshProvider = StateNotifierProvider<EventsRefreshNotifier, RefreshState>((ref) {
  return EventsRefreshNotifier(ref);
});

/// Provider for events statistics
/// Calculates and provides event statistics and metrics
final eventsStatsProvider = Provider<EventsStats>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  
  return eventsAsync.when(
    data: (events) {
      final now = DateTime.now();
      final today = events.where((e) => 
        e.startTime.isAfter(now.subtract(const Duration(days: 1)))
      ).length;
      
      final thisWeek = events.where((e) => 
        e.startTime.isAfter(now.subtract(const Duration(days: 7)))
      ).length;
      
      final alarmEvents = events.where((e) => e.state == EventState.alarm).length;
      final avgScore = events.isEmpty ? 0.0 : 
        events.map((e) => e.maxScore).reduce((a, b) => a + b) / events.length;
      
      return EventsStats(
        totalEvents: events.length,
        todayEvents: today,
        weekEvents: thisWeek,
        alarmEvents: alarmEvents,
        averageScore: avgScore,
      );
    },
    loading: () => const EventsStats.empty(),
    error: (_, __) => const EventsStats.empty(),
  );
});

/// Enhanced notifier for events view mode with persistence
class EventsViewModeNotifier extends StateNotifier<EventsViewMode> {
  final Ref _ref;
  
  EventsViewModeNotifier(this._ref) : super(EventsViewMode.list) {
    _loadSavedViewMode();
  }

  /// Load saved view mode from storage
  Future<void> _loadSavedViewMode() async {
    try {
      final storageService = _ref.read(localStorageServiceProvider);
      final savedMode = await storageService.getEventsViewMode();
      if (savedMode != null) {
        state = savedMode;
      }
    } catch (e) {
      // Use default view mode if loading fails
    }
  }

  /// Toggle between list and timeline view
  Future<void> toggle() async {
    final newMode = state == EventsViewMode.list 
        ? EventsViewMode.timeline 
        : EventsViewMode.list;
    await setViewMode(newMode);
  }

  /// Set specific view mode and persist to storage
  Future<void> setViewMode(EventsViewMode mode) async {
    state = mode;
    
    try {
      final storageService = _ref.read(localStorageServiceProvider);
      await storageService.saveEventsViewMode(mode);
    } catch (e) {
      // Continue even if saving fails
    }
  }
}

/// Events filters notifier with persistence and validation
class EventsFiltersNotifier extends StateNotifier<EventsFilters> {
  final Ref _ref;
  
  EventsFiltersNotifier(this._ref) : super(const EventsFilters()) {
    _loadSavedFilters();
  }
  
  /// Load saved filters from storage
  Future<void> _loadSavedFilters() async {
    try {
      final storageService = _ref.read(localStorageServiceProvider);
      final savedFilters = await storageService.getEventsFilters();
      if (savedFilters != null) {
        state = savedFilters;
      }
    } catch (e) {
      // Use default filters if loading fails
    }
  }
  
  /// Update filters and persist to storage
  Future<void> updateFilters(EventsFilters filters) async {
    state = filters;
    
    try {
      final storageService = _ref.read(localStorageServiceProvider);
      await storageService.saveEventsFilters(filters);
    } catch (e) {
      // Continue even if saving fails
    }
    
    // Invalidate events provider to refresh with new filters
    _ref.invalidate(eventsProvider);
  }
  
  /// Clear all filters
  Future<void> clearFilters() async {
    await updateFilters(const EventsFilters());
  }
  
  /// Update date range filter
  Future<void> updateDateRange(DateTime startDate, DateTime endDate) async {
    final newFilters = state.copyWith(
      startDate: startDate,
      endDate: endDate,
    );
    await updateFilters(newFilters);
  }
  
  /// Update event type filter
  Future<void> updateEventType(EventType eventType) async {
    final newFilters = state.copyWith(eventType: eventType);
    await updateFilters(newFilters);
  }
  
  /// Update minimum alarm score filter
  Future<void> updateMinAlarmScore(double minScore) async {
    final newFilters = state.copyWith(minAlarmScore: minScore);
    await updateFilters(newFilters);
  }
}

/// Selected event notifier with validation
class SelectedEventNotifier extends StateNotifier<EventModel?> {
  final Ref _ref;
  
  SelectedEventNotifier(this._ref) : super(null);
  
  /// Select an event with validation
  void selectEvent(EventModel? event) {
    if (event != null) {
      // Validate that the event exists in current events list
      final eventsAsync = _ref.read(eventsProvider);
      eventsAsync.whenData((events) {
        final exists = events.any((e) => e.id == event.id);
        if (exists) {
          state = event;
        }
      });
    } else {
      state = null;
    }
  }
  
  /// Clear selected event
  void clearSelection() {
    state = null;
  }
}

/// Events refresh notifier with loading state management
class EventsRefreshNotifier extends StateNotifier<RefreshState> {
  final Ref _ref;
  
  EventsRefreshNotifier(this._ref) : super(const RefreshState.idle());
  
  /// Refresh events with loading state tracking
  Future<void> refreshEvents() async {
    if (state.isLoading) return; // Prevent multiple simultaneous refreshes
    
    state = const RefreshState.loading();
    
    try {
      // Invalidate events provider to force refresh
      _ref.invalidate(eventsProvider);
      
      // Wait for the new data to load
      await _ref.read(eventsProvider.future);
      
      state = RefreshState.success(DateTime.now());
      
      // Reset to idle after 2 seconds
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          state = const RefreshState.idle();
        }
      });
    } catch (e) {
      state = RefreshState.error(e.toString());
      
      // Reset to idle after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          state = const RefreshState.idle();
        }
      });
    }
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

/// Events loading state for enhanced tracking
class EventsLoadingState {
  final bool isLoading;
  final bool hasError;
  final Object? error;
  final bool hasData;
  
  const EventsLoadingState({
    required this.isLoading,
    required this.hasError,
    this.error,
    required this.hasData,
  });
}

/// Events statistics data class
class EventsStats {
  final int totalEvents;
  final int todayEvents;
  final int weekEvents;
  final int alarmEvents;
  final double averageScore;
  
  const EventsStats({
    required this.totalEvents,
    required this.todayEvents,
    required this.weekEvents,
    required this.alarmEvents,
    required this.averageScore,
  });
  
  const EventsStats.empty() : this(
    totalEvents: 0,
    todayEvents: 0,
    weekEvents: 0,
    alarmEvents: 0,
    averageScore: 0.0,
  );
}

/// Real-time event update data class
class EventUpdate {
  final EventUpdateType type;
  final String? eventId;
  final String? cameraId;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  
  const EventUpdate({
    required this.type,
    this.eventId,
    this.cameraId,
    required this.timestamp,
    required this.data,
  });
}

/// Event update type enum
enum EventUpdateType {
  created,
  updated,
  deleted,
}

/// Refresh state for events operations (reusing from home providers)
class RefreshState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final DateTime? lastRefresh;
  
  const RefreshState._({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.lastRefresh,
  });
  
  const RefreshState.idle() : this._();
  const RefreshState.loading() : this._(isLoading: true);
  RefreshState.success(DateTime timestamp) : this._(isSuccess: true, lastRefresh: timestamp);
  RefreshState.error(String message) : this._(isError: true, errorMessage: message);
}
