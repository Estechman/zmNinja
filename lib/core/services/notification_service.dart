import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notification service provider for managing push notifications
/// Handles Firebase Cloud Messaging and local notifications
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Service class for handling push notifications from ZoneMinder
/// Integrates Firebase Cloud Messaging for real-time alerts
class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Initialize notification service with platform-specific settings
  static Future<void> initialize() async {
    try {
      // Request notification permissions
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    } catch (e) {
      // Firebase not available - continue without push notifications for static UI
      print('Firebase messaging initialization skipped: $e');
    }

    try {
      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
    } catch (e) {
      // Local notifications not available - continue without them for static UI
      print('Local notifications initialization skipped: $e');
    }
  }

  /// Initialize WebSocket connection for real-time notifications
  static Future<void> initializeWebSocket(String serverUrl, String? authToken) async {
    try {
      // TODO: Implement WebSocket connection to ZoneMinder for real-time events
      print('WebSocket initialization for real-time notifications: $serverUrl');
    } catch (e) {
      print('WebSocket initialization failed: $e');
    }
  }

  /// Get FCM token for device registration with ZoneMinder
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Firebase token unavailable: $e');
      return null;
    }
  }

  /// Subscribe to ZoneMinder event notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      print('Firebase topic subscription unavailable: $e');
    }
  }

  /// Unsubscribe from ZoneMinder event notifications
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Firebase topic unsubscription unavailable: $e');
    }
  }

  /// Show local notification for ZoneMinder events
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'zm_events',
        'ZoneMinder Events',
        channelDescription: 'Notifications for ZoneMinder security events',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
        macOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      print('Local notification unavailable: $e');
    }
  }

  /// Handle notification tap events
  static void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to appropriate screen based on payload
    // Example: Navigate to events screen or specific camera
  }

  /// Handle foreground message reception
  static void _handleForegroundMessage(RemoteMessage message) {
    // TODO: Show in-app notification or update UI
    // Example: Update event count, show snackbar
  }

  /// Handle notification tap when app is in background
  static void _handleNotificationTap(RemoteMessage message) {
    // TODO: Navigate to appropriate screen based on message data
    // Example: Open specific event or camera view
  }
}

/// Background message handler for Firebase Cloud Messaging
/// Must be top-level function for Firebase to call
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // TODO: Handle background notification processing
  // Example: Update local database, show notification
}
