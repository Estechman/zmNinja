import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';
import '../widgets/server_settings_widget.dart';
import '../widgets/notification_settings_widget.dart';
import '../widgets/display_settings_widget.dart';
import '../widgets/security_settings_widget.dart';

/// Settings screen for app configuration
/// Provides access to all app settings and preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          // Reset settings button
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _showResetDialog(context, ref),
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      
      body: settings.when(
        data: (settingsData) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Server Configuration Section
            _SettingsSection(
              title: 'ZoneMinder Server',
              icon: Icons.dns,
              child: ServerSettingsWidget(settings: settingsData),
            ),
            
            const SizedBox(height: 24),
            
            // Notification Settings Section
            _SettingsSection(
              title: 'Notifications',
              icon: Icons.notifications,
              child: NotificationSettingsWidget(settings: settingsData),
            ),
            
            const SizedBox(height: 24),
            
            // Display Settings Section
            _SettingsSection(
              title: 'Display',
              icon: Icons.display_settings,
              child: DisplaySettingsWidget(settings: settingsData),
            ),
            
            const SizedBox(height: 24),
            
            // Security Settings Section
            _SettingsSection(
              title: 'Security',
              icon: Icons.security,
              child: SecuritySettingsWidget(settings: settingsData),
            ),
            
            const SizedBox(height: 24),
            
            // About Section
            _SettingsSection(
              title: 'About',
              icon: Icons.info,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('Version'),
                    subtitle: const Text('1.0.0+1'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showVersionDialog(context),
                  ),
                  ListTile(
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  ListTile(
                    title: const Text('Open Source Licenses'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLicenses(context),
                  ),
                  ListTile(
                    title: const Text('Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showSupport(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text('Error loading settings: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(appSettingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show reset settings confirmation dialog
  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(appSettingsProvider.notifier).resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Show version information dialog
  void _showVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('zmNinja'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0+1'),
            SizedBox(height: 8),
            Text('Build: Flutter 3.8.1'),
            SizedBox(height: 8),
            Text('© 2025 ZoneMinder Community'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show privacy policy
  void _showPrivacyPolicy(BuildContext context) {
    // TODO: Implement privacy policy display
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy coming soon...')),
    );
  }

  /// Show open source licenses
  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'zmNinja',
      applicationVersion: '1.0.0+1',
      applicationLegalese: '© 2025 ZoneMinder Community',
    );
  }

  /// Show support information
  void _showSupport(BuildContext context) {
    // TODO: Implement support page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support page coming soon...')),
    );
  }
}

/// Settings section widget for grouping related settings
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
