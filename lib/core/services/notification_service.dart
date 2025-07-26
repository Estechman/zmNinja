import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      // Connect to ZoneMinder WebSocket for real-time event notifications
      final wsUrl = serverUrl.replaceFirst('http', 'ws') + '/ws';
      print('Connecting to ZoneMinder WebSocket: $wsUrl');
      
      // The WebSocket service will handle the actual connection
      // and forward events to the notification system
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
    final payload = response.payload;
    if (payload != null) {
      try {
        // Parse notification payload to determine navigation
        if (payload.contains('event:')) {
          final eventId = payload.split(':')[1];
          // Navigate to event detail screen
          _navigateToEvent(eventId);
        } else if (payload.contains('camera:')) {
          final cameraId = payload.split(':')[1];
          // Navigate to camera detail screen
          _navigateToCamera(cameraId);
        } else {
          // Default to events screen
          _navigateToEvents();
        }
      } catch (e) {
        // Fallback to events screen on parsing error
        _navigateToEvents();
      }
    }
  }

  /// Navigate to specific event
  static void _navigateToEvent(String eventId) {
    // TODO: Implement navigation to event detail screen using router
    // This would typically use the app router service
    print('Navigate to event: $eventId');
  }

  /// Navigate to specific camera
  static void _navigateToCamera(String cameraId) {
    // TODO: Implement navigation to camera detail screen using router
    print('Navigate to camera: $cameraId');
  }

  /// Navigate to events screen
  static void _navigateToEvents() {
    // TODO: Implement navigation to events screen using router
    print('Navigate to events screen');
  }

  /// Handle foreground message reception
  static void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    
    if (notification != null) {
      // Show local notification for ZoneMinder events
      final notificationService = NotificationService();
      notificationService.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: notification.title ?? 'ZoneMinder Alert',
        body: notification.body ?? 'New security event detected',
        payload: _buildPayload(data),
      );
    }
    
    // Update UI state for real-time event updates
    _updateEventCounters(data);
  }

  /// Build notification payload for navigation
  static String _buildPayload(Map<String, dynamic> data) {
    if (data.containsKey('eventId')) {
      return 'event:${data['eventId']}';
    } else if (data.containsKey('cameraId')) {
      return 'camera:${data['cameraId']}';
    }
    return 'events';
  }

  /// Update event counters and UI state
  static void _updateEventCounters(Map<String, dynamic> data) {
    // TODO: Update Riverpod providers for real-time event counts
    // This would typically refresh the events provider
    print('Updating event counters: $data');
  }

  /// Handle notification tap when app is in background
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    
    // Handle navigation based on message data
    if (data.containsKey('eventId')) {
      _navigateToEvent(data['eventId']);
    } else if (data.containsKey('cameraId')) {
      _navigateToCamera(data['cameraId']);
    } else {
      _navigateToEvents();
    }
  }
}

/// Background message handler for Firebase Cloud Messaging
/// Must be top-level function for Firebase to call
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notification processing for ZoneMinder events
  final data = message.data;
  final notification = message.notification;
  
  if (notification != null) {
    // Show notification even when app is in background
    final notificationService = NotificationService();
    await notificationService.showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notification.title ?? 'ZoneMinder Alert',
      body: notification.body ?? 'Security event detected',
      payload: NotificationService._buildPayload(data),
    );
  }
  
  // Update local storage with new event data if available
  if (data.containsKey('eventId')) {
    // TODO: Store event data locally for offline access
    print('Background event received: ${data['eventId']}');
  }
}
