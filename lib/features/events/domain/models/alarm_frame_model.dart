import 'package:freezed_annotation/freezed_annotation.dart';

part 'alarm_frame_model.freezed.dart';
part 'alarm_frame_model.g.dart';

@freezed
class AlarmFrame with _$AlarmFrame {
  const factory AlarmFrame({
    required int frameNumber,
    required double timestamp,
    required double score,
    required String imagePath,
    String? cause,
    Map<String, dynamic>? metadata,
  }) = _AlarmFrame;

  factory AlarmFrame.fromJson(Map<String, dynamic> json) =>
      _$AlarmFrameFromJson(json);
}

@freezed
class EventPlaybackState with _$EventPlaybackState {
  const factory EventPlaybackState({
    @Default(false) bool isPlaying,
    @Default(0) int currentFrame,
    @Default(0.0) double playbackSpeed,
    @Default(false) bool showAlarmFramesOnly,
    @Default([]) List<AlarmFrame> alarmFrames,
    @Default(0) int totalFrames,
  }) = _EventPlaybackState;

  factory EventPlaybackState.fromJson(Map<String, dynamic> json) =>
      _$EventPlaybackStateFromJson(json);
}
