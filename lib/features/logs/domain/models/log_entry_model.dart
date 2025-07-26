import 'package:json_annotation/json_annotation.dart';

part 'log_entry_model.g.dart';

/// Log entry model representing system log entries
/// Contains log level, message, timestamp, and metadata
@JsonSerializable()
class LogEntry {
  final String id;
  final LogLevel level;
  final String message;
  final String source;
  final DateTime timestamp;
  final String? details;
  final String? stackTrace;
  final Map<String, dynamic>? metadata;

  const LogEntry({
    required this.id,
    required this.level,
    required this.message,
    required this.source,
    required this.timestamp,
    this.details,
    this.stackTrace,
    this.metadata,
  });

  /// Create LogEntry from JSON
  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);

  /// Convert LogEntry to JSON
  Map<String, dynamic> toJson() => _$LogEntryToJson(this);

  /// Get formatted timestamp string
  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}';
  }

  /// Get formatted date string
  String get formattedDate {
    return '${timestamp.year}-'
           '${timestamp.month.toString().padLeft(2, '0')}-'
           '${timestamp.day.toString().padLeft(2, '0')}';
  }

  /// Check if log entry has additional details
  bool get hasDetails => details != null && details!.isNotEmpty;

  /// Check if log entry has stack trace
  bool get hasStackTrace => stackTrace != null && stackTrace!.isNotEmpty;

  /// Check if log entry has metadata
  bool get hasMetadata => metadata != null && metadata!.isNotEmpty;

  /// Create copy of log entry with updated properties
  LogEntry copyWith({
    String? id,
    LogLevel? level,
    String? message,
    String? source,
    DateTime? timestamp,
    String? details,
    String? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    return LogEntry(
      id: id ?? this.id,
      level: level ?? this.level,
      message: message ?? this.message,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Log level enum for categorizing log entries
@JsonEnum()
enum LogLevel {
  @JsonValue('debug')
  debug,
  @JsonValue('info')
  info,
  @JsonValue('warning')
  warning,
  @JsonValue('error')
  error,
  @JsonValue('fatal')
  fatal,
}
