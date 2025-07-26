import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_settings_model.dart';
import '../providers/settings_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart' as notif;

/// Notification settings widget for push notification preferences
/// Manages notification options, sounds, and quiet hours
class NotificationSettingsWidget extends ConsumerWidget {
  final AppSettings settings;

  const NotificationSettingsWidget({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettings = settings.notificationSettings;
    final notificationPermissions = ref.watch(notif.notificationPermissionsProvider);
    final fcmToken = ref.watch(notif.fcmTokenProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notification permissions status
        notificationPermissions.when(
          data: (hasPermission) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasPermission ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasPermission ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasPermission ? Icons.check_circle : Icons.warning,
                  color: hasPermission ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasPermission 
                      ? 'Push notifications enabled'
                      : 'Push notification permissions required',
                    style: TextStyle(
                      color: hasPermission ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // Enable notifications
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive push notifications for events'),
          value: notificationSettings.enabled,
          onChanged: (value) => _updateNotificationSettings(
            ref,
            notificationSettings.copyWith(enabled: value),
          ),
        ),

        if (notificationSettings.enabled) ...[
          const Divider(),

          // Sound settings
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Play sound for notifications'),
            value: notificationSettings.soundEnabled,
            onChanged: (value) => _updateNotificationSettings(
              ref,
              notificationSettings.copyWith(soundEnabled: value),
            ),
          ),

          // Vibration settings
          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('Vibrate for notifications'),
            value: notificationSettings.vibrationEnabled,
            onChanged: (value) => _updateNotificationSettings(
              ref,
              notificationSettings.copyWith(vibrationEnabled: value),
            ),
          ),

          // Show preview
          SwitchListTile(
            title: const Text('Show Preview'),
            subtitle: const Text('Show event details in notification'),
            value: notificationSettings.showPreview,
            onChanged: (value) => _updateNotificationSettings(
              ref,
              notificationSettings.copyWith(showPreview: value),
            ),
          ),

          const Divider(),

          // Priority setting
          ListTile(
            title: const Text('Priority'),
            subtitle: Text('Current: ${notificationSettings.priority.name}'),
            trailing: DropdownButton<NotificationPriority>(
              value: notificationSettings.priority,
              onChanged: (value) {
                if (value != null) {
                  _updateNotificationSettings(
                    ref,
                    notificationSettings.copyWith(priority: value),
                  );
                }
              },
              items: NotificationPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name.toUpperCase()),
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // Quiet hours
          ExpansionTile(
            title: const Text('Quiet Hours'),
            subtitle: Text(
              '${_formatHour(notificationSettings.quietHoursStart)} - '
              '${_formatHour(notificationSettings.quietHoursEnd)}',
            ),
            children: [
              // Start time
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(_formatHour(notificationSettings.quietHoursStart)),
                trailing: TextButton(
                  onPressed: () => _selectQuietHour(
                    context,
                    ref,
                    notificationSettings,
                    isStart: true,
                  ),
                  child: const Text('Change'),
                ),
              ),

              // End time
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(_formatHour(notificationSettings.quietHoursEnd)),
                trailing: TextButton(
                  onPressed: () => _selectQuietHour(
                    context,
                    ref,
                    notificationSettings,
                    isStart: false,
                  ),
                  child: const Text('Change'),
                ),
              ),
            ],
          ),

          const Divider(),

          // Camera selection
          ExpansionTile(
            title: const Text('Camera Notifications'),
            subtitle: Text(
              notificationSettings.enabledCameras.isEmpty
                  ? 'All cameras'
                  : '${notificationSettings.enabledCameras.length} cameras selected',
            ),
            children: [
              ListTile(
                title: const Text('Select Cameras'),
                subtitle: const Text('Choose which cameras send notifications'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showCameraSelection(context, ref, notificationSettings),
              ),
            ],
          ),

          const Divider(),

          // Test notification button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: notificationSettings.enabled ? () {
                  // Test notification using the notification service
                  final notificationService = ref.read(notif.notificationServiceProvider);
                  notificationService.showLocalNotification(
                    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                    title: 'Test Notification',
                    body: 'This is a test notification from zmNinja',
                    payload: 'test',
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test notification sent'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } : null,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Test Notification'),
              ),
            ),
          ),

          // FCM Token info (for debugging)
          fcmToken.when(
            data: (token) => token != null ? ExpansionTile(
              title: const Text('Device Token'),
              subtitle: const Text('For debugging push notifications'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SelectableText(
                    token,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ) : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }

  /// Update notification settings
  void _updateNotificationSettings(
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    ref.read(appSettingsProvider.notifier).updateNotificationSettings(settings);
  }

  /// Format hour for display
  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:00 $period';
  }

  /// Select quiet hour
  void _selectQuietHour(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
    {required bool isStart}
  ) async {
    final currentHour = isStart ? settings.quietHoursStart : settings.quietHoursEnd;
    
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (time != null) {
      final updatedSettings = isStart
          ? settings.copyWith(quietHoursStart: time.hour)
          : settings.copyWith(quietHoursEnd: time.hour);
      
      _updateNotificationSettings(ref, updatedSettings);
    }
  }

  /// Show camera selection dialog
  void _showCameraSelection(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    // TODO: Implement camera selection with available cameras
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Cameras'),
        content: const Text('Camera selection coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
