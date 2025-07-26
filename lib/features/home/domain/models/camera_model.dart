import 'package:json_annotation/json_annotation.dart';

part 'camera_model.g.dart';

/// Camera/Monitor model representing ZoneMinder camera configuration
/// Contains all camera properties and status information
@JsonSerializable()
class CameraModel {
  final String id;
  final String name;
  final String? description;
  final String streamUrl;
  final String? thumbnailUrl;
  final bool isOnline;
  final bool isRecording;
  final bool hasPtz;
  final CameraFunction function;
  final int width;
  final int height;
  final String? host;
  final int? port;
  final String? path;

  const CameraModel({
    required this.id,
    required this.name,
    this.description,
    required this.streamUrl,
    this.thumbnailUrl,
    required this.isOnline,
    required this.isRecording,
    required this.hasPtz,
    required this.function,
    required this.width,
    required this.height,
    this.host,
    this.port,
    this.path,
  });

  /// Create CameraModel from JSON (ZoneMinder API response)
  factory CameraModel.fromJson(Map<String, dynamic> json) =>
      _$CameraModelFromJson(json);

  /// Convert CameraModel to JSON
  Map<String, dynamic> toJson() => _$CameraModelToJson(this);

  /// Create copy of camera with updated properties
  CameraModel copyWith({
    String? id,
    String? name,
    String? description,
    String? streamUrl,
    String? thumbnailUrl,
    bool? isOnline,
    bool? isRecording,
    bool? hasPtz,
    CameraFunction? function,
    int? width,
    int? height,
    String? host,
    int? port,
    String? path,
  }) {
    return CameraModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      streamUrl: streamUrl ?? this.streamUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isOnline: isOnline ?? this.isOnline,
      isRecording: isRecording ?? this.isRecording,
      hasPtz: hasPtz ?? this.hasPtz,
      function: function ?? this.function,
      width: width ?? this.width,
      height: height ?? this.height,
      host: host ?? this.host,
      port: port ?? this.port,
      path: path ?? this.path,
    );
  }
}

/// Camera function enum matching ZoneMinder monitor functions
@JsonEnum()
enum CameraFunction {
  @JsonValue('None')
  none,
  @JsonValue('Monitor')
  monitor,
  @JsonValue('Modect')
  modect,
  @JsonValue('Record')
  record,
  @JsonValue('Mocord')
  mocord,
  @JsonValue('Nodect')
  nodect,
}
