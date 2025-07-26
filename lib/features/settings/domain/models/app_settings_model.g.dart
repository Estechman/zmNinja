// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
  serverSettings: json['serverSettings'] == null
      ? const ServerSettings()
      : ServerSettings.fromJson(json['serverSettings'] as Map<String, dynamic>),
  notificationSettings: json['notificationSettings'] == null
      ? const NotificationSettings()
      : NotificationSettings.fromJson(
          json['notificationSettings'] as Map<String, dynamic>,
        ),
  displaySettings: json['displaySettings'] == null
      ? const DisplaySettings()
      : DisplaySettings.fromJson(
          json['displaySettings'] as Map<String, dynamic>,
        ),
  securitySettings: json['securitySettings'] == null
      ? const SecuritySettings()
      : SecuritySettings.fromJson(
          json['securitySettings'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'serverSettings': instance.serverSettings,
      'notificationSettings': instance.notificationSettings,
      'displaySettings': instance.displaySettings,
      'securitySettings': instance.securitySettings,
    };

ServerSettings _$ServerSettingsFromJson(Map<String, dynamic> json) =>
    ServerSettings(
      serverUrl: json['serverUrl'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      useHttps: json['useHttps'] as bool? ?? true,
      port: (json['port'] as num?)?.toInt() ?? 443,
      apiPath: json['apiPath'] as String? ?? '/zm/api',
      connectionTimeout: (json['connectionTimeout'] as num?)?.toInt() ?? 30,
      verifySSL: json['verifySSL'] as bool? ?? true,
    );

Map<String, dynamic> _$ServerSettingsToJson(ServerSettings instance) =>
    <String, dynamic>{
      'serverUrl': instance.serverUrl,
      'username': instance.username,
      'password': instance.password,
      'useHttps': instance.useHttps,
      'port': instance.port,
      'apiPath': instance.apiPath,
      'connectionTimeout': instance.connectionTimeout,
      'verifySSL': instance.verifySSL,
    };

NotificationSettings _$NotificationSettingsFromJson(
  Map<String, dynamic> json,
) => NotificationSettings(
  enabled: json['enabled'] as bool? ?? true,
  soundEnabled: json['soundEnabled'] as bool? ?? true,
  vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
  showPreview: json['showPreview'] as bool? ?? true,
  enabledCameras:
      (json['enabledCameras'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  priority:
      $enumDecodeNullable(_$NotificationPriorityEnumMap, json['priority']) ??
      NotificationPriority.high,
  quietHoursStart: (json['quietHoursStart'] as num?)?.toInt() ?? 22,
  quietHoursEnd: (json['quietHoursEnd'] as num?)?.toInt() ?? 7,
);

Map<String, dynamic> _$NotificationSettingsToJson(
  NotificationSettings instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'soundEnabled': instance.soundEnabled,
  'vibrationEnabled': instance.vibrationEnabled,
  'showPreview': instance.showPreview,
  'enabledCameras': instance.enabledCameras,
  'priority': _$NotificationPriorityEnumMap[instance.priority]!,
  'quietHoursStart': instance.quietHoursStart,
  'quietHoursEnd': instance.quietHoursEnd,
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.max: 'max',
};

DisplaySettings _$DisplaySettingsFromJson(Map<String, dynamic> json) =>
    DisplaySettings(
      themeMode:
          $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
          AppThemeMode.system,
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      showCameraNames: json['showCameraNames'] as bool? ?? true,
      showTimestamps: json['showTimestamps'] as bool? ?? true,
      defaultGridLayout:
          $enumDecodeNullable(_$GridLayoutEnumMap, json['defaultGridLayout']) ??
          GridLayout.auto,
      streamQuality:
          $enumDecodeNullable(_$VideoQualityEnumMap, json['streamQuality']) ??
          VideoQuality.medium,
      keepScreenOn: json['keepScreenOn'] as bool? ?? false,
    );

Map<String, dynamic> _$DisplaySettingsToJson(DisplaySettings instance) =>
    <String, dynamic>{
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
      'textScale': instance.textScale,
      'showCameraNames': instance.showCameraNames,
      'showTimestamps': instance.showTimestamps,
      'defaultGridLayout': _$GridLayoutEnumMap[instance.defaultGridLayout]!,
      'streamQuality': _$VideoQualityEnumMap[instance.streamQuality]!,
      'keepScreenOn': instance.keepScreenOn,
    };

const _$AppThemeModeEnumMap = {
  AppThemeMode.system: 'system',
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
};

const _$GridLayoutEnumMap = {
  GridLayout.auto: 'auto',
  GridLayout.single: 'single',
  GridLayout.quad: 'quad',
  GridLayout.nine: 'nine',
  GridLayout.sixteen: 'sixteen',
};

const _$VideoQualityEnumMap = {
  VideoQuality.low: 'low',
  VideoQuality.medium: 'medium',
  VideoQuality.high: 'high',
  VideoQuality.ultra: 'ultra',
};

SecuritySettings _$SecuritySettingsFromJson(Map<String, dynamic> json) =>
    SecuritySettings(
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      pinEnabled: json['pinEnabled'] as bool? ?? false,
      pinCode: json['pinCode'] as String?,
      autoLockMinutes: (json['autoLockMinutes'] as num?)?.toInt() ?? 5,
      hideInRecents: json['hideInRecents'] as bool? ?? false,
      allowScreenshots: json['allowScreenshots'] as bool? ?? true,
    );

Map<String, dynamic> _$SecuritySettingsToJson(SecuritySettings instance) =>
    <String, dynamic>{
      'biometricEnabled': instance.biometricEnabled,
      'pinEnabled': instance.pinEnabled,
      'pinCode': instance.pinCode,
      'autoLockMinutes': instance.autoLockMinutes,
      'hideInRecents': instance.hideInRecents,
      'allowScreenshots': instance.allowScreenshots,
    };
