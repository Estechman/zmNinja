import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/logs_providers.dart';
import '../../domain/models/log_entry_model.dart';

/// Widget for filtering logs by level, source, and search query
/// Provides filter chips and search functionality for log entries
class LogFilterWidget extends ConsumerWidget {
  const LogFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logLevel = ref.watch(logLevelFilterProvider);
    final searchQuery = ref.watch(logSearchProvider);
    final sourceFilter = ref.watch(logSourceFilterProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search logs...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) => ref.read(logSearchProvider.notifier).state = value,
          ),

          const SizedBox(height: 12),

          // Filter chips
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              // Log level filter
              FilterChip(
                label: Text('Level: ${logLevel.name.toUpperCase()}'),
                selected: logLevel != LogLevel.debug,
                onSelected: (selected) => _showLogLevelPicker(context, ref),
              ),

              // Source filter
              FilterChip(
                label: Text(sourceFilter != null 
                    ? 'Source: $sourceFilter'
                    : 'All Sources'),
                selected: sourceFilter != null,
                onSelected: (selected) => _showSourcePicker(context, ref),
              ),

              // Clear filters
              if (searchQuery.isNotEmpty || 
                  logLevel != LogLevel.debug || 
                  sourceFilter != null)
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

  /// Clear all filters
  void _clearFilters(WidgetRef ref) {
    ref.read(logSearchProvider.notifier).state = '';
    ref.read(logLevelFilterProvider.notifier).state = LogLevel.debug;
    ref.read(logSourceFilterProvider.notifier).state = null;
  }

  /// Show log level picker dialog
  void _showLogLevelPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Log Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LogLevel.values.map((level) {
            return ListTile(
              leading: Icon(
                _getLogLevelIcon(level),
                color: _getLogLevelColor(level),
              ),
              title: Text(level.name.toUpperCase()),
              subtitle: Text(_getLogLevelDescription(level)),
              onTap: () {
                Navigator.pop(context);
                ref.read(logLevelFilterProvider.notifier).state = level;
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

  /// Show source picker dialog
  void _showSourcePicker(BuildContext context, WidgetRef ref) {
    // TODO: Get available sources from logs provider
    final availableSources = [
      'API',
      'Camera',
      'Events',
      'PTZ',
      'Settings',
      'Notifications',
      'Database',
      'Network',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Sources'),
              onTap: () {
                Navigator.pop(context);
                ref.read(logSourceFilterProvider.notifier).state = null;
              },
            ),
            const Divider(),
            ...availableSources.map((source) {
              return ListTile(
                title: Text(source),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(logSourceFilterProvider.notifier).state = source;
                },
              );
            }),
          ],
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

  /// Get description for log level
  String _getLogLevelDescription(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'Show all logs including debug information';
      case LogLevel.info:
        return 'Show informational messages and above';
      case LogLevel.warning:
        return 'Show warnings, errors, and fatal messages';
      case LogLevel.error:
        return 'Show only errors and fatal messages';
      case LogLevel.fatal:
        return 'Show only fatal error messages';
    }
  }
}
