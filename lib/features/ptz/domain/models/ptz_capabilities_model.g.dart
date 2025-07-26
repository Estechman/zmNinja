// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ptz_capabilities_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PtzCapabilities _$PtzCapabilitiesFromJson(Map<String, dynamic> json) =>
    PtzCapabilities(
      canMove: json['canMove'] as bool,
      canZoom: json['canZoom'] as bool,
      canFocus: json['canFocus'] as bool,
      canIris: json['canIris'] as bool,
      canWhiteBalance: json['canWhiteBalance'] as bool,
      canPresets: json['canPresets'] as bool,
      canHome: json['canHome'] as bool,
      canReset: json['canReset'] as bool,
      canReboot: json['canReboot'] as bool,
      maxPresets: (json['maxPresets'] as num).toInt(),
      minPan: (json['minPan'] as num).toDouble(),
      maxPan: (json['maxPan'] as num).toDouble(),
      minTilt: (json['minTilt'] as num).toDouble(),
      maxTilt: (json['maxTilt'] as num).toDouble(),
      minZoom: (json['minZoom'] as num).toDouble(),
      maxZoom: (json['maxZoom'] as num).toDouble(),
      supportedCommands: (json['supportedCommands'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PtzCapabilitiesToJson(PtzCapabilities instance) =>
    <String, dynamic>{
      'canMove': instance.canMove,
      'canZoom': instance.canZoom,
      'canFocus': instance.canFocus,
      'canIris': instance.canIris,
      'canWhiteBalance': instance.canWhiteBalance,
      'canPresets': instance.canPresets,
      'canHome': instance.canHome,
      'canReset': instance.canReset,
      'canReboot': instance.canReboot,
      'maxPresets': instance.maxPresets,
      'minPan': instance.minPan,
      'maxPan': instance.maxPan,
      'minTilt': instance.minTilt,
      'maxTilt': instance.maxTilt,
      'minZoom': instance.minZoom,
      'maxZoom': instance.maxZoom,
      'supportedCommands': instance.supportedCommands,
    };
