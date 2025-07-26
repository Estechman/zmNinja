// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraModel _$CameraModelFromJson(Map<String, dynamic> json) => CameraModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  streamUrl: json['streamUrl'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  isOnline: json['isOnline'] as bool,
  isRecording: json['isRecording'] as bool,
  hasPtz: json['hasPtz'] as bool,
  function: $enumDecode(_$CameraFunctionEnumMap, json['function']),
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  host: json['host'] as String?,
  port: (json['port'] as num?)?.toInt(),
  path: json['path'] as String?,
);

Map<String, dynamic> _$CameraModelToJson(CameraModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'streamUrl': instance.streamUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'isOnline': instance.isOnline,
      'isRecording': instance.isRecording,
      'hasPtz': instance.hasPtz,
      'function': _$CameraFunctionEnumMap[instance.function]!,
      'width': instance.width,
      'height': instance.height,
      'host': instance.host,
      'port': instance.port,
      'path': instance.path,
    };

const _$CameraFunctionEnumMap = {
  CameraFunction.none: 'None',
  CameraFunction.monitor: 'Monitor',
  CameraFunction.modect: 'Modect',
  CameraFunction.record: 'Record',
  CameraFunction.mocord: 'Mocord',
  CameraFunction.nodect: 'Nodect',
};
