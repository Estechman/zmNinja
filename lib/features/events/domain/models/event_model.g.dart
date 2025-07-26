// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
  id: json['id'] as String,
  cameraId: json['cameraId'] as String,
  cameraName: json['cameraName'] as String,
  name: json['name'] as String,
  cause: json['cause'] as String?,
  notes: json['notes'] as String?,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  length: (json['length'] as num).toInt(),
  frames: (json['frames'] as num).toInt(),
  alarmFrames: (json['alarmFrames'] as num).toInt(),
  maxScore: (json['maxScore'] as num).toDouble(),
  avgScore: (json['avgScore'] as num).toDouble(),
  thumbnailPath: json['thumbnailPath'] as String?,
  videoPath: json['videoPath'] as String?,
  state: $enumDecode(_$EventStateEnumMap, json['state']),
  archived: json['archived'] as bool,
);

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cameraId': instance.cameraId,
      'cameraName': instance.cameraName,
      'name': instance.name,
      'cause': instance.cause,
      'notes': instance.notes,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'length': instance.length,
      'frames': instance.frames,
      'alarmFrames': instance.alarmFrames,
      'maxScore': instance.maxScore,
      'avgScore': instance.avgScore,
      'thumbnailPath': instance.thumbnailPath,
      'videoPath': instance.videoPath,
      'state': _$EventStateEnumMap[instance.state]!,
      'archived': instance.archived,
    };

const _$EventStateEnumMap = {
  EventState.idle: 'Idle',
  EventState.prealarm: 'Prealarm',
  EventState.alarm: 'Alarm',
  EventState.alert: 'Alert',
  EventState.tape: 'Tape',
};
