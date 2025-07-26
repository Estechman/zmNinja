// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ptz_preset_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PtzPreset _$PtzPresetFromJson(Map<String, dynamic> json) => PtzPreset(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  pan: (json['pan'] as num?)?.toDouble(),
  tilt: (json['tilt'] as num?)?.toDouble(),
  zoom: (json['zoom'] as num?)?.toDouble(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isDefault: json['isDefault'] as bool,
);

Map<String, dynamic> _$PtzPresetToJson(PtzPreset instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'pan': instance.pan,
  'tilt': instance.tilt,
  'zoom': instance.zoom,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isDefault': instance.isDefault,
};
