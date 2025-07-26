import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../features/settings/domain/models/app_settings_model.dart';

/// Provider for settings service
/// Manages persistent storage of application settings
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// Service class for managing application settings
/// Handles loading, saving, and validation of user preferences
class SettingsService {
  static const String _settingsKey = 'app_settings';
  
  /// Load settings from persistent storage
  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        return AppSettings.fromJson(settingsMap);
      }
      
      // Return default settings if none found
      return const AppSettings();
    } catch (e) {
      // Return default settings on error
      return const AppSettings();
    }
  }

  /// Get current app settings (synchronous access for providers)
  Future<AppSettings> getAppSettings() async {
    return await loadSettings();
  }

  /// Save settings to persistent storage
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  /// Test connection to ZoneMinder server
  Future<bool> testConnection(ServerSettings serverSettings) async {
    if (!serverSettings.isConfigured) {
      return false;
    }

    try {
      // TODO: Implement actual connection test to ZoneMinder API
      // This would typically involve making a test API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate network call
      return true; // Placeholder - always returns true for now
    } catch (e) {
      return false;
    }
  }

  /// Clear all settings (reset to defaults)
  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
    } catch (e) {
      throw Exception('Failed to clear settings: $e');
    }
  }

  /// Export settings as JSON string
  Future<String> exportSettings() async {
    final settings = await loadSettings();
    return json.encode(settings.toJson());
  }

  /// Import settings from JSON string
  Future<void> importSettings(String settingsJson) async {
    try {
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      final settings = AppSettings.fromJson(settingsMap);
      await saveSettings(settings);
    } catch (e) {
      throw Exception('Failed to import settings: $e');
    }
  }

  /// Validate server settings
  bool validateServerSettings(ServerSettings settings) {
    if (!settings.isConfigured) return false;
    
    // Basic URL validation
    final url = settings.serverUrl!;
    if (!url.contains('.') || url.length < 3) return false;
    
    // Port validation
    if (settings.port < 1 || settings.port > 65535) return false;
    
    return true;
  }

  /// Get settings version for migration purposes
  Future<int> getSettingsVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('settings_version') ?? 1;
    } catch (e) {
      return 1;
    }
  }

  /// Set settings version
  Future<void> setSettingsVersion(int version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('settings_version', version);
    } catch (e) {
      throw Exception('Failed to set settings version: $e');
    }
  }
}
