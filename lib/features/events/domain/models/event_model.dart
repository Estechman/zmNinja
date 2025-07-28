import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

/// Event model representing ZoneMinder recorded events
/// Contains event metadata, timestamps, and associated media
@JsonSerializable()
class EventModel {
  final String id;
  final String cameraId;
  final String cameraName;
  final String name;
  final String? cause;
  final String? notes;
  final DateTime startTime;
  final DateTime? endTime;
  final int length; // Duration in seconds
  final int frames;
  final int alarmFrames;
  final double maxScore;
  final double avgScore;
  final String? thumbnailPath;
  final String? videoPath;
  final EventState state;
  final bool archived;

  const EventModel({
    required this.id,
    required this.cameraId,
    required this.cameraName,
    required this.name,
    this.cause,
    this.notes,
    required this.startTime,
    this.endTime,
    required this.length,
    required this.frames,
    required this.alarmFrames,
    required this.maxScore,
    required this.avgScore,
    this.thumbnailPath,
    this.videoPath,
    required this.state,
    required this.archived,
  });

  /// Create EventModel from JSON (ZoneMinder API response)
  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  /// Convert EventModel to JSON
  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  /// Get event duration as formatted string
  String get durationString {
    final duration = Duration(seconds: length);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if event is currently recording
  bool get isRecording => endTime == null;

  /// Get alarm percentage
  double get alarmPercentage {
    if (frames == 0) return 0.0;
    return (alarmFrames / frames) * 100;
  }

  /// Monitor name alias for compatibility
  String? get monitorName => cameraName;
  
  /// Monitor ID alias for compatibility  
  String get monitorId => cameraId;

  /// Create copy of event with updated properties
  EventModel copyWith({
    String? id,
    String? cameraId,
    String? cameraName,
    String? name,
    String? cause,
    String? notes,
    DateTime? startTime,
    DateTime? endTime,
    int? length,
    int? frames,
    int? alarmFrames,
    double? maxScore,
    double? avgScore,
    String? thumbnailPath,
    String? videoPath,
    EventState? state,
    bool? archived,
  }) {
    return EventModel(
      id: id ?? this.id,
      cameraId: cameraId ?? this.cameraId,
      cameraName: cameraName ?? this.cameraName,
      name: name ?? this.name,
      cause: cause ?? this.cause,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      length: length ?? this.length,
      frames: frames ?? this.frames,
      alarmFrames: alarmFrames ?? this.alarmFrames,
      maxScore: maxScore ?? this.maxScore,
      avgScore: avgScore ?? this.avgScore,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      videoPath: videoPath ?? this.videoPath,
      state: state ?? this.state,
      archived: archived ?? this.archived,
    );
  }
}

/// Event state enum matching ZoneMinder event states
@JsonEnum()
enum EventState {
  @JsonValue('Idle')
  idle,
  @JsonValue('Prealarm')
  prealarm,
  @JsonValue('Alarm')
  alarm,
  @JsonValue('Alert')
  alert,
  @JsonValue('Tape')
  tape,
}
