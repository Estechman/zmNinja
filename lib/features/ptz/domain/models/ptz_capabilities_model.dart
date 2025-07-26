import 'package:json_annotation/json_annotation.dart';

part 'ptz_capabilities_model.g.dart';

/// PTZ capabilities model representing camera PTZ features
/// Contains information about supported PTZ operations
@JsonSerializable()
class PtzCapabilities {
  final bool canMove;
  final bool canZoom;
  final bool canFocus;
  final bool canIris;
  final bool canWhiteBalance;
  final bool canPresets;
  final bool canHome;
  final bool canReset;
  final bool canReboot;
  final int maxPresets;
  final double minPan;
  final double maxPan;
  final double minTilt;
  final double maxTilt;
  final double minZoom;
  final double maxZoom;
  final List<String> supportedCommands;

  const PtzCapabilities({
    required this.canMove,
    required this.canZoom,
    required this.canFocus,
    required this.canIris,
    required this.canWhiteBalance,
    required this.canPresets,
    required this.canHome,
    required this.canReset,
    required this.canReboot,
    required this.maxPresets,
    required this.minPan,
    required this.maxPan,
    required this.minTilt,
    required this.maxTilt,
    required this.minZoom,
    required this.maxZoom,
    required this.supportedCommands,
  });

  /// Create PtzCapabilities from JSON (ZoneMinder API response)
  factory PtzCapabilities.fromJson(Map<String, dynamic> json) =>
      _$PtzCapabilitiesFromJson(json);

  /// Convert PtzCapabilities to JSON
  Map<String, dynamic> toJson() => _$PtzCapabilitiesToJson(this);

  /// Check if camera supports basic PTZ operations
  bool get hasBasicPtz => canMove || canZoom;

  /// Check if camera supports advanced PTZ features
  bool get hasAdvancedPtz => canFocus || canIris || canWhiteBalance;

  /// Get list of available movement directions
  List<String> get availableDirections {
    if (!canMove) return [];
    return ['up', 'down', 'left', 'right', 'up_left', 'up_right', 'down_left', 'down_right'];
  }
}
