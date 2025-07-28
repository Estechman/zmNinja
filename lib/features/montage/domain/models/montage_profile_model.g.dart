// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'montage_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MontageProfileImpl _$$MontageProfileImplFromJson(Map<String, dynamic> json) =>
    _$MontageProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      cameraLayouts: (json['cameraLayouts'] as List<dynamic>)
          .map((e) => CameraLayout.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MontageProfileImplToJson(
  _$MontageProfileImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'cameraLayouts': instance.cameraLayouts,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$CameraLayoutImpl _$$CameraLayoutImplFromJson(Map<String, dynamic> json) =>
    _$CameraLayoutImpl(
      cameraId: json['cameraId'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      visible: json['visible'] as bool,
      gridScale: (json['gridScale'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$$CameraLayoutImplToJson(_$CameraLayoutImpl instance) =>
    <String, dynamic>{
      'cameraId': instance.cameraId,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'visible': instance.visible,
      'gridScale': instance.gridScale,
    };

_$AlarmStatusUpdateImpl _$$AlarmStatusUpdateImplFromJson(
  Map<String, dynamic> json,
) => _$AlarmStatusUpdateImpl(
  cameraId: json['cameraId'] as String,
  status: $enumDecode(_$AlarmStatusEnumMap, json['status']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  eventCount: (json['eventCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$$AlarmStatusUpdateImplToJson(
  _$AlarmStatusUpdateImpl instance,
) => <String, dynamic>{
  'cameraId': instance.cameraId,
  'status': _$AlarmStatusEnumMap[instance.status]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'eventCount': instance.eventCount,
};

const _$AlarmStatusEnumMap = {
  AlarmStatus.idle: 'idle',
  AlarmStatus.alert: 'alert',
  AlarmStatus.alarmed: 'alarmed',
  AlarmStatus.recording: 'recording',
  AlarmStatus.offline: 'offline',
};

_$EventCountUpdateImpl _$$EventCountUpdateImplFromJson(
  Map<String, dynamic> json,
) => _$EventCountUpdateImpl(
  cameraId: json['cameraId'] as String,
  newEventId: json['newEventId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$EventCountUpdateImplToJson(
  _$EventCountUpdateImpl instance,
) => <String, dynamic>{
  'cameraId': instance.cameraId,
  'newEventId': instance.newEventId,
  'timestamp': instance.timestamp.toIso8601String(),
};
