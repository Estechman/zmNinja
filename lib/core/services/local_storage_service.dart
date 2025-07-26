import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

import '../../features/home/domain/models/camera_model.dart';
import '../../features/events/domain/models/event_model.dart';

/// Provider for local storage service
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// Service for managing local SQLite database
/// Handles caching of cameras, events, and user data for offline functionality
class LocalStorageService {
  static Database? _database;
  static const String _databaseName = 'zmNinja.db';
  static const int _databaseVersion = 1;

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize SQLite database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// Create database tables
  Future<void> _createTables(Database db, int version) async {
    // Cameras table
    await db.execute('''
      CREATE TABLE cameras (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        streamUrl TEXT,
        isOnline INTEGER NOT NULL,
        isRecording INTEGER NOT NULL,
        hasPtz INTEGER NOT NULL,
        function TEXT NOT NULL,
        width INTEGER NOT NULL,
        height INTEGER NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        cameraId TEXT NOT NULL,
        cameraName TEXT NOT NULL,
        name TEXT NOT NULL,
        cause TEXT NOT NULL,
        notes TEXT,
        startTime INTEGER NOT NULL,
        endTime INTEGER NOT NULL,
        length INTEGER NOT NULL,
        frames INTEGER NOT NULL,
        alarmFrames INTEGER NOT NULL,
        maxScore REAL NOT NULL,
        avgScore REAL NOT NULL,
        thumbnailPath TEXT,
        videoPath TEXT,
        state TEXT NOT NULL,
        archived INTEGER NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    // User preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');
  }

  /// Upgrade database schema
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  /// Cache cameras data
  Future<void> cacheCameras(List<CameraModel> cameras) async {
    final db = await database;
    final batch = db.batch();

    // Clear existing cameras
    batch.delete('cameras');

    // Insert new cameras
    for (final camera in cameras) {
      batch.insert('cameras', {
        'id': camera.id,
        'name': camera.name,
        'streamUrl': camera.streamUrl,
        'isOnline': camera.isOnline ? 1 : 0,
        'isRecording': camera.isRecording ? 1 : 0,
        'hasPtz': camera.hasPtz ? 1 : 0,
        'function': camera.function.name,
        'width': camera.width,
        'height': camera.height,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
    }

    await batch.commit();
  }

  /// Get cached cameras
  Future<List<CameraModel>> getCachedCameras() async {
    final db = await database;
    final maps = await db.query('cameras', orderBy: 'name ASC');

    return maps.map((map) => CameraModel(
      id: map['id'] as String,
      name: map['name'] as String,
      streamUrl: map['streamUrl'] as String? ?? '',
      isOnline: (map['isOnline'] as int) == 1,
      isRecording: (map['isRecording'] as int) == 1,
      hasPtz: (map['hasPtz'] as int) == 1,
      function: CameraFunction.values.firstWhere(
        (f) => f.name == map['function'],
        orElse: () => CameraFunction.monitor,
      ),
      width: map['width'] as int,
      height: map['height'] as int,
    )).toList();
  }

  /// Cache events data
  Future<void> cacheEvents(List<EventModel> events) async {
    final db = await database;
    final batch = db.batch();

    // Insert or replace events
    for (final event in events) {
      batch.insert('events', {
        'id': event.id,
        'cameraId': event.cameraId,
        'cameraName': event.cameraName,
        'name': event.name,
        'cause': event.cause,
        'notes': event.notes,
        'startTime': event.startTime.millisecondsSinceEpoch,
        'endTime': event.endTime?.millisecondsSinceEpoch ?? event.startTime.millisecondsSinceEpoch,
        'length': event.length,
        'frames': event.frames,
        'alarmFrames': event.alarmFrames,
        'maxScore': event.maxScore,
        'avgScore': event.avgScore,
        'thumbnailPath': event.thumbnailPath,
        'videoPath': event.videoPath,
        'state': event.state.name,
        'archived': event.archived ? 1 : 0,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  /// Get cached events
  Future<List<EventModel>> getCachedEvents({String? cameraId}) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (cameraId != null) {
      whereClause = 'WHERE cameraId = ?';
      whereArgs = [cameraId];
    }
    
    final maps = await db.query(
      'events',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'startTime DESC',
      limit: 100,
    );

    return maps.map((map) => EventModel(
      id: map['id'] as String,
      cameraId: map['cameraId'] as String,
      cameraName: map['cameraName'] as String,
      name: map['name'] as String,
      cause: map['cause'] as String,
      notes: map['notes'] as String? ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
      length: map['length'] as int,
      frames: map['frames'] as int,
      alarmFrames: map['alarmFrames'] as int,
      maxScore: map['maxScore'] as double,
      avgScore: map['avgScore'] as double,
      thumbnailPath: map['thumbnailPath'] as String? ?? '',
      videoPath: map['videoPath'] as String? ?? '',
      state: EventState.values.firstWhere(
        (s) => s.name == map['state'],
        orElse: () => EventState.idle,
      ),
      archived: (map['archived'] as int) == 1,
    )).toList();
  }

  /// Store user preference
  Future<void> setUserPreference(String key, dynamic value) async {
    final db = await database;
    await db.insert(
      'user_preferences',
      {
        'key': key,
        'value': json.encode(value),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user preference
  Future<T?> getUserPreference<T>(String key) async {
    final db = await database;
    final maps = await db.query(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      final value = maps.first['value'] as String;
      return json.decode(value) as T;
    }

    return null;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    final db = await database;
    final batch = db.batch();
    
    batch.delete('cameras');
    batch.delete('events');
    
    await batch.commit();
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
