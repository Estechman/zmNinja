import 'package:freezed_annotation/freezed_annotation.dart';

part 'montage_profile_model.freezed.dart';
part 'montage_profile_model.g.dart';

/// Enum for alarm status states
enum AlarmStatus {
  idle,
  alert,
  alarmed,
  recording,
  offline,
}

@freezed
class MontageProfile with _$MontageProfile {
  const factory MontageProfile({
    required String id,
    required String name,
    required List<CameraLayout> cameraLayouts,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _MontageProfile;

  factory MontageProfile.fromJson(Map<String, dynamic> json) =>
      _$MontageProfileFromJson(json);
}

@freezed
class CameraLayout with _$CameraLayout {
  const factory CameraLayout({
    required String cameraId,
    required double x,
    required double y,
    required double width,
    required double height,
    required bool visible,
    @Default(20) int gridScale,
  }) = _CameraLayout;

  factory CameraLayout.fromJson(Map<String, dynamic> json) =>
      _$CameraLayoutFromJson(json);
}


@freezed
class AlarmStatusUpdate with _$AlarmStatusUpdate {
  const factory AlarmStatusUpdate({
    required String cameraId,
    required AlarmStatus status,
    required DateTime timestamp,
    int? eventCount,
  }) = _AlarmStatusUpdate;

  factory AlarmStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$AlarmStatusUpdateFromJson(json);
}

@freezed
class EventCountUpdate with _$EventCountUpdate {
  const factory EventCountUpdate({
    required String cameraId,
    required String newEventId,
    required DateTime timestamp,
  }) = _EventCountUpdate;

  factory EventCountUpdate.fromJson(Map<String, dynamic> json) =>
      _$EventCountUpdateFromJson(json);
}
