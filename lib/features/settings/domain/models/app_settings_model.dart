import 'package:json_annotation/json_annotation.dart';

part 'app_settings_model.g.dart';

/// Application settings model containing all user preferences
/// Manages configuration for server, notifications, display, and security
@JsonSerializable()
class AppSettings {
  final ServerSettings serverSettings;
  final NotificationSettings notificationSettings;
  final DisplaySettings displaySettings;
  final SecuritySettings securitySettings;

  const AppSettings({
    this.serverSettings = const ServerSettings(),
    this.notificationSettings = const NotificationSettings(),
    this.displaySettings = const DisplaySettings(),
    this.securitySettings = const SecuritySettings(),
  });

  /// Create AppSettings from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  /// Convert AppSettings to JSON
  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  /// Create copy with updated settings
  AppSettings copyWith({
    ServerSettings? serverSettings,
    NotificationSettings? notificationSettings,
    DisplaySettings? displaySettings,
    SecuritySettings? securitySettings,
  }) {
    return AppSettings(
      serverSettings: serverSettings ?? this.serverSettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      displaySettings: displaySettings ?? this.displaySettings,
      securitySettings: securitySettings ?? this.securitySettings,
    );
  }
}

/// Server settings for ZoneMinder configuration
@JsonSerializable()
class ServerSettings {
  final String? serverUrl;
  final String? username;
  final String? password;
  final bool useHttps;
  final int port;
  final String? apiPath;
  final int connectionTimeout;
  final bool verifySSL;

  const ServerSettings({
    this.serverUrl,
    this.username,
    this.password,
    this.useHttps = true,
    this.port = 443,
    this.apiPath = '/zm/api',
    this.connectionTimeout = 30,
    this.verifySSL = true,
  });

  factory ServerSettings.fromJson(Map<String, dynamic> json) =>
      _$ServerSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ServerSettingsToJson(this);

  /// Get full server URL
  String? get fullUrl {
    if (serverUrl == null) return null;
    final protocol = useHttps ? 'https' : 'http';
    final portSuffix = (useHttps && port == 443) || (!useHttps && port == 80) ? '' : ':$port';
    return '$protocol://$serverUrl$portSuffix$apiPath';
  }

  /// Check if server is configured
  bool get isConfigured => serverUrl != null && serverUrl!.isNotEmpty;

  ServerSettings copyWith({
    String? serverUrl,
    String? username,
    String? password,
    bool? useHttps,
    int? port,
    String? apiPath,
    int? connectionTimeout,
    bool? verifySSL,
  }) {
    return ServerSettings(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      useHttps: useHttps ?? this.useHttps,
      port: port ?? this.port,
      apiPath: apiPath ?? this.apiPath,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      verifySSL: verifySSL ?? this.verifySSL,
    );
  }
}

/// Notification settings for push notifications
@JsonSerializable()
class NotificationSettings {
  final bool enabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showPreview;
  final List<String> enabledCameras;
  final NotificationPriority priority;
  final int quietHoursStart;
  final int quietHoursEnd;

  const NotificationSettings({
    this.enabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showPreview = true,
    this.enabledCameras = const [],
    this.priority = NotificationPriority.high,
    this.quietHoursStart = 22, // 10 PM
    this.quietHoursEnd = 7,    // 7 AM
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);

  NotificationSettings copyWith({
    bool? enabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showPreview,
    List<String>? enabledCameras,
    NotificationPriority? priority,
    int? quietHoursStart,
    int? quietHoursEnd,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showPreview: showPreview ?? this.showPreview,
      enabledCameras: enabledCameras ?? this.enabledCameras,
      priority: priority ?? this.priority,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

/// Display settings for UI preferences
@JsonSerializable()
class DisplaySettings {
  final AppThemeMode themeMode;
  final double textScale;
  final bool showCameraNames;
  final bool showTimestamps;
  final GridLayout defaultGridLayout;
  final VideoQuality streamQuality;
  final bool keepScreenOn;

  const DisplaySettings({
    this.themeMode = AppThemeMode.system,
    this.textScale = 1.0,
    this.showCameraNames = true,
    this.showTimestamps = true,
    this.defaultGridLayout = GridLayout.auto,
    this.streamQuality = VideoQuality.medium,
    this.keepScreenOn = false,
  });

  factory DisplaySettings.fromJson(Map<String, dynamic> json) =>
      _$DisplaySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$DisplaySettingsToJson(this);

  DisplaySettings copyWith({
    AppThemeMode? themeMode,
    double? textScale,
    bool? showCameraNames,
    bool? showTimestamps,
    GridLayout? defaultGridLayout,
    VideoQuality? streamQuality,
    bool? keepScreenOn,
  }) {
    return DisplaySettings(
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
      showCameraNames: showCameraNames ?? this.showCameraNames,
      showTimestamps: showTimestamps ?? this.showTimestamps,
      defaultGridLayout: defaultGridLayout ?? this.defaultGridLayout,
      streamQuality: streamQuality ?? this.streamQuality,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }
}

/// Security settings for app protection
@JsonSerializable()
class SecuritySettings {
  final bool biometricEnabled;
  final bool pinEnabled;
  final String? pinCode;
  final int autoLockMinutes;
  final bool hideInRecents;
  final bool allowScreenshots;

  const SecuritySettings({
    this.biometricEnabled = false,
    this.pinEnabled = false,
    this.pinCode,
    this.autoLockMinutes = 5,
    this.hideInRecents = false,
    this.allowScreenshots = true,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) =>
      _$SecuritySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SecuritySettingsToJson(this);

  /// Check if any security features are enabled
  bool get hasSecurityEnabled => biometricEnabled || pinEnabled;

  SecuritySettings copyWith({
    bool? biometricEnabled,
    bool? pinEnabled,
    String? pinCode,
    int? autoLockMinutes,
    bool? hideInRecents,
    bool? allowScreenshots,
  }) {
    return SecuritySettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      pinCode: pinCode ?? this.pinCode,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      hideInRecents: hideInRecents ?? this.hideInRecents,
      allowScreenshots: allowScreenshots ?? this.allowScreenshots,
    );
  }
}

/// Notification priority enum
@JsonEnum()
enum NotificationPriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('max')
  max,
}

/// Theme mode enum
@JsonEnum()
enum AppThemeMode {
  @JsonValue('system')
  system,
  @JsonValue('light')
  light,
  @JsonValue('dark')
  dark,
}

/// Grid layout enum
@JsonEnum()
enum GridLayout {
  @JsonValue('auto')
  auto,
  @JsonValue('single')
  single,
  @JsonValue('quad')
  quad,
  @JsonValue('nine')
  nine,
  @JsonValue('sixteen')
  sixteen,
}

/// Video quality enum
@JsonEnum()
enum VideoQuality {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('ultra')
  ultra,
}
