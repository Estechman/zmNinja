import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

import '../../features/home/domain/models/camera_model.dart';
import '../../features/events/domain/models/event_model.dart';
import '../../features/home/presentation/providers/home_providers.dart';
import '../../features/events/presentation/providers/events_providers.dart';
import '../../features/montage/domain/models/montage_profile_model.dart';

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

    // Montage profiles table
    await db.execute('''
      CREATE TABLE montage_profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        cameraLayouts TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER
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

  /// Get grid layout preference
  Future<GridLayout?> getGridLayout() async {
    try {
      final layoutName = await getUserPreference<String>('grid_layout');
      if (layoutName != null) {
        return GridLayout.values.firstWhere(
          (layout) => layout.name == layoutName,
          orElse: () => GridLayout.auto,
        );
      }
    } catch (e) {
      // Return null if preference doesn't exist or parsing fails
    }
    return null;
  }

  /// Save grid layout preference
  Future<void> saveGridLayout(GridLayout layout) async {
    await setUserPreference('grid_layout', layout.name);
  }

  /// Get events view mode preference
  Future<EventsViewMode?> getEventsViewMode() async {
    try {
      final modeName = await getUserPreference<String>('events_view_mode');
      if (modeName != null) {
        return EventsViewMode.values.firstWhere(
          (mode) => mode.name == modeName,
          orElse: () => EventsViewMode.list,
        );
      }
    } catch (e) {
      // Return null if preference doesn't exist or parsing fails
    }
    return null;
  }

  /// Save events view mode preference
  Future<void> saveEventsViewMode(EventsViewMode mode) async {
    await setUserPreference('events_view_mode', mode.name);
  }

  /// Get events filters preference
  Future<EventsFilters?> getEventsFilters() async {
    try {
      final filtersMap = await getUserPreference<Map<String, dynamic>>('events_filters');
      if (filtersMap != null) {
        return EventsFilters(
          startDate: filtersMap['startDate'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(filtersMap['startDate'] as int)
            : null,
          endDate: filtersMap['endDate'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(filtersMap['endDate'] as int)
            : null,
          cameraId: filtersMap['cameraId'] as String?,
          eventType: filtersMap['eventType'] != null
            ? EventType.values.firstWhere(
                (type) => type.name == filtersMap['eventType'],
                orElse: () => EventType.motion,
              )
            : null,
          minAlarmScore: filtersMap['minAlarmScore'] as double?,
        );
      }
    } catch (e) {
      // Return null if preference doesn't exist or parsing fails
    }
    return null;
  }

  /// Save events filters preference
  Future<void> saveEventsFilters(EventsFilters filters) async {
    final filtersMap = <String, dynamic>{
      'startDate': filters.startDate?.millisecondsSinceEpoch,
      'endDate': filters.endDate?.millisecondsSinceEpoch,
      'cameraId': filters.cameraId,
      'eventType': filters.eventType?.name,
      'minAlarmScore': filters.minAlarmScore,
    };
    await setUserPreference('events_filters', filtersMap);
  }

  /// Get montage profiles from local storage
  Future<List<MontageProfile>> getMontageProfiles() async {
    final db = await database;
    final maps = await db.query('montage_profiles', orderBy: 'createdAt DESC');

    return maps.map((map) => MontageProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      cameraLayouts: (json.decode(map['cameraLayouts'] as String) as List)
          .map((layout) => CameraLayout.fromJson(layout as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
    )).toList();
  }

  /// Save montage profile to local storage
  Future<void> saveMontageProfile(MontageProfile profile) async {
    final db = await database;
    await db.insert(
      'montage_profiles',
      {
        'id': profile.id,
        'name': profile.name,
        'cameraLayouts': json.encode(profile.cameraLayouts.map((layout) => layout.toJson()).toList()),
        'createdAt': profile.createdAt.millisecondsSinceEpoch,
        'updatedAt': profile.updatedAt?.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete montage profile from local storage
  Future<void> deleteMontageProfile(String profileId) async {
    final db = await database;
    await db.delete(
      'montage_profiles',
      where: 'id = ?',
      whereArgs: [profileId],
    );
  }

  /// Get camera order from local storage
  Future<List<String>> getCameraOrder() async {
    try {
      final orderJson = await getUserPreference<String>('camera_order');
      if (orderJson == null) return [];
      
      final orderList = json.decode(orderJson) as List;
      return orderList.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Save camera order to local storage
  Future<void> saveCameraOrder(List<String> order) async {
    await setUserPreference('camera_order', json.encode(order));
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
