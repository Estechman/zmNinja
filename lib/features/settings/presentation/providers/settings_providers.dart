import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_settings_model.dart';
import '../../../../core/services/settings_service.dart';

/// Provider for app settings
/// Manages all application settings and preferences
final appSettingsProvider = AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(() {
  return AppSettingsNotifier();
});

/// Provider for server settings
/// Manages ZoneMinder server configuration
final serverSettingsProvider = Provider<ServerSettings>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.when(
    data: (appSettings) => appSettings.serverSettings,
    loading: () => const ServerSettings(),
    error: (_, __) => const ServerSettings(),
  );
});

/// Provider for notification settings
/// Manages push notification preferences
final notificationSettingsProvider = Provider<NotificationSettings>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.when(
    data: (appSettings) => appSettings.notificationSettings,
    loading: () => const NotificationSettings(),
    error: (_, __) => const NotificationSettings(),
  );
});

/// Provider for display settings
/// Manages UI and display preferences
final displaySettingsProvider = Provider<DisplaySettings>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.when(
    data: (appSettings) => appSettings.displaySettings,
    loading: () => const DisplaySettings(),
    error: (_, __) => const DisplaySettings(),
  );
});

/// Provider for security settings
/// Manages app security and authentication preferences
final securitySettingsProvider = Provider<SecuritySettings>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.when(
    data: (appSettings) => appSettings.securitySettings,
    loading: () => const SecuritySettings(),
    error: (_, __) => const SecuritySettings(),
  );
});

/// Notifier for app settings management
class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final settingsService = ref.watch(settingsServiceProvider);
    return await settingsService.loadSettings();
  }

  /// Update server settings
  Future<void> updateServerSettings(ServerSettings serverSettings) async {
    final settingsService = ref.watch(settingsServiceProvider);
    final currentSettings = await future;
    final updatedSettings = currentSettings.copyWith(serverSettings: serverSettings);
    
    await settingsService.saveSettings(updatedSettings);
    state = AsyncValue.data(updatedSettings);
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(NotificationSettings notificationSettings) async {
    final settingsService = ref.watch(settingsServiceProvider);
    final currentSettings = await future;
    final updatedSettings = currentSettings.copyWith(notificationSettings: notificationSettings);
    
    await settingsService.saveSettings(updatedSettings);
    state = AsyncValue.data(updatedSettings);
  }

  /// Update display settings
  Future<void> updateDisplaySettings(DisplaySettings displaySettings) async {
    final settingsService = ref.watch(settingsServiceProvider);
    final currentSettings = await future;
    final updatedSettings = currentSettings.copyWith(displaySettings: displaySettings);
    
    await settingsService.saveSettings(updatedSettings);
    state = AsyncValue.data(updatedSettings);
  }

  /// Update security settings
  Future<void> updateSecuritySettings(SecuritySettings securitySettings) async {
    final settingsService = ref.watch(settingsServiceProvider);
    final currentSettings = await future;
    final updatedSettings = currentSettings.copyWith(securitySettings: securitySettings);
    
    await settingsService.saveSettings(updatedSettings);
    state = AsyncValue.data(updatedSettings);
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    final settingsService = ref.watch(settingsServiceProvider);
    const defaultSettings = AppSettings();
    
    await settingsService.saveSettings(defaultSettings);
    state = const AsyncValue.data(defaultSettings);
  }

  /// Test server connection
  Future<bool> testServerConnection() async {
    final settingsService = ref.watch(settingsServiceProvider);
    final currentSettings = await future;
    return await settingsService.testConnection(currentSettings.serverSettings);
  }
}
