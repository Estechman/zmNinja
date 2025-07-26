import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/log_entry_model.dart';
import '../providers/logs_providers.dart';
import '../widgets/log_entry_widget.dart';
import '../widgets/log_filter_widget.dart';

/// Logs screen for viewing system logs and debugging information
/// Displays application logs with filtering and search capabilities
class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(logsProvider);
    final logLevel = ref.watch(logLevelFilterProvider);
    final isAutoRefresh = ref.watch(autoRefreshProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Logs'),
        actions: [
          // Log level filter
          PopupMenuButton<LogLevel>(
            icon: const Icon(Icons.filter_list),
            onSelected: (level) => ref.read(logLevelFilterProvider.notifier).state = level,
            itemBuilder: (context) => LogLevel.values.map((level) {
              return PopupMenuItem(
                value: level,
                child: Row(
                  children: [
                    Icon(
                      _getLogLevelIcon(level),
                      color: _getLogLevelColor(level),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(level.name.toUpperCase()),
                    if (level == logLevel) ...[
                      const Spacer(),
                      const Icon(Icons.check, size: 16),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          
          // Auto-refresh toggle
          IconButton(
            icon: Icon(isAutoRefresh ? Icons.pause : Icons.play_arrow),
            onPressed: () => ref.read(autoRefreshProvider.notifier).toggle(),
            tooltip: isAutoRefresh ? 'Pause Auto-refresh' : 'Start Auto-refresh',
          ),
          
          // Manual refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(logsProvider),
          ),
          
          // Clear logs
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _showClearLogsDialog(context, ref),
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Log filters
          const LogFilterWidget(),
          
          // Logs list
          Expanded(
            child: logs.when(
              data: (logEntries) {
                final filteredLogs = logEntries
                    .where((log) => _shouldShowLog(log, logLevel))
                    .toList();

                if (filteredLogs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description, size: 64),
                        SizedBox(height: 16),
                        Text('No logs found'),
                        SizedBox(height: 8),
                        Text('Try adjusting your filters'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true, // Show newest logs first
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    return LogEntryWidget(
                      logEntry: log,
                      onTap: () => _showLogDetails(context, log),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    Text('Error loading logs: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(logsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Floating action button for exporting logs
      floatingActionButton: FloatingActionButton(
        onPressed: () => _exportLogs(context, ref),
        tooltip: 'Export Logs',
        child: const Icon(Icons.file_download),
      ),
    );
  }

  /// Check if log should be shown based on current filter
  bool _shouldShowLog(LogEntry log, LogLevel filterLevel) {
    return log.level.index >= filterLevel.index;
  }

  /// Get icon for log level
  IconData _getLogLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Icons.bug_report;
      case LogLevel.info:
        return Icons.info;
      case LogLevel.warning:
        return Icons.warning;
      case LogLevel.error:
        return Icons.error;
      case LogLevel.fatal:
        return Icons.dangerous;
    }
  }

  /// Get color for log level
  Color _getLogLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.fatal:
        return Colors.purple;
    }
  }

  /// Show clear logs confirmation dialog
  void _showClearLogsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text(
          'Are you sure you want to clear all logs? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(logsProvider.notifier).clearLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs cleared')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Show detailed log entry dialog
  void _showLogDetails(BuildContext context, LogEntry log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Details - ${log.level.name.toUpperCase()}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time: ${log.timestamp}'),
              const SizedBox(height: 8),
              Text('Source: ${log.source}'),
              const SizedBox(height: 8),
              Text('Message: ${log.message}'),
              if (log.details != null) ...[
                const SizedBox(height: 8),
                Text('Details: ${log.details}'),
              ],
              if (log.stackTrace != null) ...[
                const SizedBox(height: 8),
                Text('Stack Trace: ${log.stackTrace}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Export logs to file
  void _exportLogs(BuildContext context, WidgetRef ref) {
    // TODO: Implement log export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log export coming soon...')),
    );
  }
}
