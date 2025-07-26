import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/services/settings_service.dart';

/// Provider for notification service instance
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for FCM token
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.getToken();
});

/// Provider for notification permissions status
final notificationPermissionsProvider = FutureProvider<bool>((ref) async {
  try {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  } catch (e) {
    // Firebase not available - return false for development
    return false;
  }
});

/// Provider for managing notification subscriptions
final notificationSubscriptionProvider = StateNotifierProvider<NotificationSubscriptionNotifier, Set<String>>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationSubscriptionNotifier(notificationService);
});

/// Notifier for managing notification topic subscriptions
class NotificationSubscriptionNotifier extends StateNotifier<Set<String>> {
  final NotificationService _notificationService;
  
  NotificationSubscriptionNotifier(this._notificationService) : super(<String>{});

  /// Subscribe to a notification topic
  Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
    state = {...state, topic};
  }

  /// Unsubscribe from a notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
    state = state.where((t) => t != topic).toSet();
  }

  /// Subscribe to all camera events
  Future<void> subscribeToAllCameras() async {
    await subscribeToTopic('zm_events');
    await subscribeToTopic('zm_alarms');
  }

  /// Unsubscribe from all notifications
  Future<void> unsubscribeFromAll() async {
    for (final topic in state) {
      await unsubscribeFromTopic(topic);
    }
  }
}

/// Provider for real-time notification integration with WebSocket
final realtimeNotificationProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final websocketService = ref.watch(websocketServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  
  // Listen to WebSocket events and trigger notifications
  return websocketService.eventStream.map((event) {
    // Show local notification for real-time events
    if (event['type'] == 'alarm' || event['type'] == 'event') {
      notificationService.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'ZoneMinder Alert',
        body: event['message'] ?? 'Security event detected',
        payload: 'event:${event['eventId'] ?? 'unknown'}',
      );
    }
    
    return event;
  });
});

/// Provider for notification settings
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return NotificationSettingsNotifier(settingsService);
});

/// Notification settings model
class NotificationSettings {
  final bool pushNotificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showPreview;
  final Set<String> enabledCameras;

  const NotificationSettings({
    this.pushNotificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showPreview = true,
    this.enabledCameras = const {},
  });

  NotificationSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showPreview,
    Set<String>? enabledCameras,
  }) {
    return NotificationSettings(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showPreview: showPreview ?? this.showPreview,
      enabledCameras: enabledCameras ?? this.enabledCameras,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'showPreview': showPreview,
      'enabledCameras': enabledCameras.toList(),
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      showPreview: json['showPreview'] ?? true,
      enabledCameras: Set<String>.from(json['enabledCameras'] ?? []),
    );
  }
}

/// Notifier for notification settings
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final SettingsService _settingsService;
  
  NotificationSettingsNotifier(this._settingsService) : super(const NotificationSettings()) {
    _loadSettings();
  }

  /// Load notification settings from storage
  Future<void> _loadSettings() async {
    try {
      final appSettings = await _settingsService.getAppSettings();
      // Extract notification settings from app settings
      // For now, use default settings
      state = const NotificationSettings();
    } catch (e) {
      // Use default settings on error
      state = const NotificationSettings();
    }
  }

  /// Update push notifications enabled status
  Future<void> setPushNotificationsEnabled(bool enabled) async {
    state = state.copyWith(pushNotificationsEnabled: enabled);
    await _saveSettings();
  }

  /// Update sound enabled status
  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _saveSettings();
  }

  /// Update vibration enabled status
  Future<void> setVibrationEnabled(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
  }

  /// Update preview enabled status
  Future<void> setShowPreview(bool enabled) async {
    state = state.copyWith(showPreview: enabled);
    await _saveSettings();
  }

  /// Enable notifications for specific camera
  Future<void> enableCameraNotifications(String cameraId) async {
    final updatedCameras = {...state.enabledCameras, cameraId};
    state = state.copyWith(enabledCameras: updatedCameras);
    await _saveSettings();
  }

  /// Disable notifications for specific camera
  Future<void> disableCameraNotifications(String cameraId) async {
    final updatedCameras = state.enabledCameras.where((id) => id != cameraId).toSet();
    state = state.copyWith(enabledCameras: updatedCameras);
    await _saveSettings();
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      // TODO: Integrate with settings service to persist notification settings
      // This would typically save to the app settings model
    } catch (e) {
      // Handle save error
    }
  }
}
