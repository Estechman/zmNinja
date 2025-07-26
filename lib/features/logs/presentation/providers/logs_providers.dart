import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/log_entry_model.dart';
import '../../../../core/services/logging_service.dart';

/// Provider for system logs
/// Manages application logs and debugging information
final logsProvider = AsyncNotifierProvider<LogsNotifier, List<LogEntry>>(() {
  return LogsNotifier();
});

/// Provider for log level filter
/// Controls which log levels are displayed
final logLevelFilterProvider = StateProvider<LogLevel>((ref) {
  return LogLevel.info; // Default to info level and above
});

/// Provider for auto-refresh state
/// Controls automatic log refresh
final autoRefreshProvider = StateNotifierProvider<AutoRefreshNotifier, bool>((ref) {
  return AutoRefreshNotifier();
});

/// Provider for log search query
/// Manages log search functionality
final logSearchProvider = StateProvider<String>((ref) {
  return '';
});

/// Provider for log source filter
/// Filters logs by source component
final logSourceFilterProvider = StateProvider<String?>((ref) {
  return null; // Show all sources by default
});

/// Notifier for logs management
class LogsNotifier extends AsyncNotifier<List<LogEntry>> {
  @override
  Future<List<LogEntry>> build() async {
    final loggingService = ref.watch(loggingServiceProvider);
    return await loggingService.getLogs();
  }

  /// Add new log entry
  void addLog(LogEntry entry) {
    final currentLogs = state.value ?? [];
    state = AsyncValue.data([...currentLogs, entry]);
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    final loggingService = ref.watch(loggingServiceProvider);
    await loggingService.clearLogs();
    state = const AsyncValue.data([]);
  }

  /// Refresh logs from service
  Future<void> refreshLogs() async {
    final loggingService = ref.watch(loggingServiceProvider);
    final logs = await loggingService.getLogs();
    state = AsyncValue.data(logs);
  }

  /// Filter logs by search query
  List<LogEntry> filterLogs(String query) {
    final logs = state.value ?? [];
    if (query.isEmpty) return logs;
    
    return logs.where((log) {
      return log.message.toLowerCase().contains(query.toLowerCase()) ||
             log.source.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Get logs by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    final logs = state.value ?? [];
    return logs.where((log) => log.level == level).toList();
  }

  /// Get logs by source
  List<LogEntry> getLogsBySource(String source) {
    final logs = state.value ?? [];
    return logs.where((log) => log.source == source).toList();
  }
}

/// Notifier for auto-refresh functionality
class AutoRefreshNotifier extends StateNotifier<bool> {
  AutoRefreshNotifier() : super(false);

  /// Toggle auto-refresh
  void toggle() {
    state = !state;
  }

  /// Enable auto-refresh
  void enable() {
    state = true;
  }

  /// Disable auto-refresh
  void disable() {
    state = false;
  }
}
