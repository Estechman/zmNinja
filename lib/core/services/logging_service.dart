import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../features/logs/domain/models/log_entry_model.dart';

/// Provider for logging service
/// Manages application logging and log storage
final loggingServiceProvider = Provider<LoggingService>((ref) {
  return LoggingService();
});

/// Service class for application logging
/// Handles log creation, storage, and retrieval
class LoggingService {
  static Database? _database;
  static const String _tableName = 'log_entries';
  static const int _maxLogEntries = 10000; // Maximum number of log entries to keep

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize SQLite database for log storage
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'zm_ninja_logs.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            level TEXT NOT NULL,
            message TEXT NOT NULL,
            source TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            details TEXT,
            stack_trace TEXT,
            metadata TEXT
          )
        ''');

        // Create index for faster queries
        await db.execute('''
          CREATE INDEX idx_timestamp ON $_tableName (timestamp DESC)
        ''');
        
        await db.execute('''
          CREATE INDEX idx_level ON $_tableName (level)
        ''');
      },
    );
  }

  /// Add log entry to database
  Future<void> addLog(LogEntry entry) async {
    final db = await database;
    
    await db.insert(
      _tableName,
      {
        'id': entry.id,
        'level': entry.level.name,
        'message': entry.message,
        'source': entry.source,
        'timestamp': entry.timestamp.millisecondsSinceEpoch,
        'details': entry.details,
        'stack_trace': entry.stackTrace,
        'metadata': entry.metadata != null ? _encodeMetadata(entry.metadata!) : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Clean up old entries if we exceed the maximum
    await _cleanupOldEntries();
  }

  /// Get all log entries
  Future<List<LogEntry>> getLogs({
    LogLevel? minLevel,
    String? source,
    DateTime? startTime,
    DateTime? endTime,
    int? limit,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    // Build WHERE clause based on filters
    final conditions = <String>[];
    
    if (minLevel != null) {
      conditions.add('level IN (${_getLevelFilter(minLevel)})');
    }
    
    if (source != null) {
      conditions.add('source = ?');
      whereArgs.add(source);
    }
    
    if (startTime != null) {
      conditions.add('timestamp >= ?');
      whereArgs.add(startTime.millisecondsSinceEpoch);
    }
    
    if (endTime != null) {
      conditions.add('timestamp <= ?');
      whereArgs.add(endTime.millisecondsSinceEpoch);
    }
    
    if (conditions.isNotEmpty) {
      whereClause = 'WHERE ${conditions.join(' AND ')}';
    }

    final result = await db.query(
      _tableName,
      where: whereClause.isEmpty ? null : whereClause.substring(6), // Remove 'WHERE '
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return result.map((row) => _logEntryFromRow(row)).toList();
  }

  /// Clear all log entries
  Future<void> clearLogs() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Get log count by level
  Future<Map<LogLevel, int>> getLogCountByLevel() async {
    final db = await database;
    
    final result = await db.rawQuery('''
      SELECT level, COUNT(*) as count 
      FROM $_tableName 
      GROUP BY level
    ''');

    final counts = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      counts[level] = 0;
    }

    for (final row in result) {
      final levelName = row['level'] as String;
      final count = row['count'] as int;
      final level = LogLevel.values.firstWhere(
        (l) => l.name == levelName,
        orElse: () => LogLevel.info,
      );
      counts[level] = count;
    }

    return counts;
  }

  /// Get log sources
  Future<List<String>> getLogSources() async {
    final db = await database;
    
    final result = await db.rawQuery('''
      SELECT DISTINCT source 
      FROM $_tableName 
      ORDER BY source
    ''');

    return result.map((row) => row['source'] as String).toList();
  }

  /// Log debug message
  void logDebug(String message, String source, {String? details, Map<String, dynamic>? metadata}) {
    _addLogEntry(LogLevel.debug, message, source, details: details, metadata: metadata);
  }

  /// Log info message
  void logInfo(String message, String source, {String? details, Map<String, dynamic>? metadata}) {
    _addLogEntry(LogLevel.info, message, source, details: details, metadata: metadata);
  }

  /// Log warning message
  void logWarning(String message, String source, {String? details, Map<String, dynamic>? metadata}) {
    _addLogEntry(LogLevel.warning, message, source, details: details, metadata: metadata);
  }

  /// Log error message
  void logError(String message, String source, {String? details, String? stackTrace, Map<String, dynamic>? metadata}) {
    _addLogEntry(LogLevel.error, message, source, details: details, stackTrace: stackTrace, metadata: metadata);
  }

  /// Log fatal message
  void logFatal(String message, String source, {String? details, String? stackTrace, Map<String, dynamic>? metadata}) {
    _addLogEntry(LogLevel.fatal, message, source, details: details, stackTrace: stackTrace, metadata: metadata);
  }

  /// Add log entry (internal method)
  void _addLogEntry(
    LogLevel level,
    String message,
    String source, {
    String? details,
    String? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final entry = LogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      level: level,
      message: message,
      source: source,
      timestamp: DateTime.now(),
      details: details,
      stackTrace: stackTrace,
      metadata: metadata,
    );

    // Add log entry asynchronously to avoid blocking
    addLog(entry).catchError((error) {
      // Silently handle logging errors to avoid infinite loops
      print('Failed to add log entry: $error');
    });
  }

  /// Clean up old log entries
  Future<void> _cleanupOldEntries() async {
    final db = await database;
    
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    ) ?? 0;

    if (count > _maxLogEntries) {
      final entriesToDelete = count - _maxLogEntries;
      await db.rawDelete('''
        DELETE FROM $_tableName 
        WHERE id IN (
          SELECT id FROM $_tableName 
          ORDER BY timestamp ASC 
          LIMIT ?
        )
      ''', [entriesToDelete]);
    }
  }

  /// Get level filter for SQL query
  String _getLevelFilter(LogLevel minLevel) {
    final levels = LogLevel.values.where((level) => level.index >= minLevel.index);
    return levels.map((level) => "'${level.name}'").join(', ');
  }

  /// Convert database row to LogEntry
  LogEntry _logEntryFromRow(Map<String, dynamic> row) {
    return LogEntry(
      id: row['id'] as String,
      level: LogLevel.values.firstWhere(
        (level) => level.name == row['level'],
        orElse: () => LogLevel.info,
      ),
      message: row['message'] as String,
      source: row['source'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
      details: row['details'] as String?,
      stackTrace: row['stack_trace'] as String?,
      metadata: row['metadata'] != null ? _decodeMetadata(row['metadata'] as String) : null,
    );
  }

  /// Encode metadata to JSON string
  String _encodeMetadata(Map<String, dynamic> metadata) {
    // TODO: Implement proper JSON encoding
    return metadata.toString();
  }

  /// Decode metadata from JSON string
  Map<String, dynamic>? _decodeMetadata(String metadata) {
    // TODO: Implement proper JSON decoding
    return null;
  }
}
