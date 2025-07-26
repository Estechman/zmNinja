import 'package:json_annotation/json_annotation.dart';

part 'ptz_preset_model.g.dart';

/// PTZ preset model representing saved camera positions
/// Contains preset position data and metadata
@JsonSerializable()
class PtzPreset {
  final int id;
  final String name;
  final String? description;
  final double? pan;
  final double? tilt;
  final double? zoom;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDefault;

  const PtzPreset({
    required this.id,
    required this.name,
    this.description,
    this.pan,
    this.tilt,
    this.zoom,
    this.createdAt,
    this.updatedAt,
    required this.isDefault,
  });

  /// Create PtzPreset from JSON (ZoneMinder API response)
  factory PtzPreset.fromJson(Map<String, dynamic> json) =>
      _$PtzPresetFromJson(json);

  /// Convert PtzPreset to JSON
  Map<String, dynamic> toJson() => _$PtzPresetToJson(this);

  /// Check if preset has position data
  bool get hasPositionData => pan != null || tilt != null || zoom != null;

  /// Get formatted position string
  String get positionString {
    if (!hasPositionData) return 'No position data';
    
    final parts = <String>[];
    if (pan != null) parts.add('Pan: ${pan!.toStringAsFixed(1)}°');
    if (tilt != null) parts.add('Tilt: ${tilt!.toStringAsFixed(1)}°');
    if (zoom != null) parts.add('Zoom: ${zoom!.toStringAsFixed(1)}x');
    
    return parts.join(', ');
  }

  /// Create copy of preset with updated properties
  PtzPreset copyWith({
    int? id,
    String? name,
    String? description,
    double? pan,
    double? tilt,
    double? zoom,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
  }) {
    return PtzPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pan: pan ?? this.pan,
      tilt: tilt ?? this.tilt,
      zoom: zoom ?? this.zoom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
