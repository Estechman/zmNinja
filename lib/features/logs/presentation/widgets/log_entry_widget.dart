import 'package:flutter/material.dart';

import '../../domain/models/log_entry_model.dart';

/// Individual log entry widget for displaying log information
/// Shows log level, timestamp, message, and source
class LogEntryWidget extends StatelessWidget {
  final LogEntry logEntry;
  final VoidCallback? onTap;

  const LogEntryWidget({
    super.key,
    required this.logEntry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Log level indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _getLogLevelColor(logEntry.level),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 12),

              // Log content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with level, time, and source
                    Row(
                      children: [
                        // Log level badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getLogLevelColor(logEntry.level),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            logEntry.level.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Timestamp
                        Text(
                          logEntry.formattedTimestamp,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),

                        const Spacer(),

                        // Source
                        Text(
                          logEntry.source,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Log message
                    Text(
                      logEntry.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Additional details indicator
                    if (logEntry.hasDetails || logEntry.hasStackTrace) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (logEntry.hasDetails)
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                          if (logEntry.hasStackTrace) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.code,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                          ],
                        ],
                      ),
                    ],

                    // Metadata indicator
                    if (logEntry.hasMetadata) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Has metadata',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Expand indicator
              if (logEntry.hasDetails || logEntry.hasStackTrace)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
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
}
