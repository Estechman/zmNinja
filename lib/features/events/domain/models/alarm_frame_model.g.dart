// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_frame_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlarmFrameImpl _$$AlarmFrameImplFromJson(Map<String, dynamic> json) =>
    _$AlarmFrameImpl(
      frameNumber: (json['frameNumber'] as num).toInt(),
      timestamp: (json['timestamp'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
      imagePath: json['imagePath'] as String,
      cause: json['cause'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AlarmFrameImplToJson(_$AlarmFrameImpl instance) =>
    <String, dynamic>{
      'frameNumber': instance.frameNumber,
      'timestamp': instance.timestamp,
      'score': instance.score,
      'imagePath': instance.imagePath,
      'cause': instance.cause,
      'metadata': instance.metadata,
    };

_$EventPlaybackStateImpl _$$EventPlaybackStateImplFromJson(
  Map<String, dynamic> json,
) => _$EventPlaybackStateImpl(
  isPlaying: json['isPlaying'] as bool? ?? false,
  currentFrame: (json['currentFrame'] as num?)?.toInt() ?? 0,
  playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 0.0,
  showAlarmFramesOnly: json['showAlarmFramesOnly'] as bool? ?? false,
  alarmFrames:
      (json['alarmFrames'] as List<dynamic>?)
          ?.map((e) => AlarmFrame.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalFrames: (json['totalFrames'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$EventPlaybackStateImplToJson(
  _$EventPlaybackStateImpl instance,
) => <String, dynamic>{
  'isPlaying': instance.isPlaying,
  'currentFrame': instance.currentFrame,
  'playbackSpeed': instance.playbackSpeed,
  'showAlarmFramesOnly': instance.showAlarmFramesOnly,
  'alarmFrames': instance.alarmFrames,
  'totalFrames': instance.totalFrames,
};
