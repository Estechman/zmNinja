import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_settings_model.dart';
import '../providers/settings_providers.dart';

/// Server settings widget for ZoneMinder configuration
/// Manages server URL, authentication, and connection settings
class ServerSettingsWidget extends ConsumerStatefulWidget {
  final AppSettings settings;

  const ServerSettingsWidget({
    super.key,
    required this.settings,
  });

  @override
  ConsumerState<ServerSettingsWidget> createState() => _ServerSettingsWidgetState();
}

class _ServerSettingsWidgetState extends ConsumerState<ServerSettingsWidget> {
  late final TextEditingController _serverUrlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _portController;
  late final TextEditingController _apiPathController;

  @override
  void initState() {
    super.initState();
    final serverSettings = widget.settings.serverSettings;
    
    _serverUrlController = TextEditingController(text: serverSettings.serverUrl);
    _usernameController = TextEditingController(text: serverSettings.username);
    _passwordController = TextEditingController(text: serverSettings.password);
    _portController = TextEditingController(text: serverSettings.port.toString());
    _apiPathController = TextEditingController(text: serverSettings.apiPath);
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _portController.dispose();
    _apiPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverSettings = widget.settings.serverSettings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Server URL
        TextField(
          controller: _serverUrlController,
          decoration: const InputDecoration(
            labelText: 'Server URL',
            hintText: 'example.com or 192.168.1.100',
            prefixIcon: Icon(Icons.dns),
          ),
          onChanged: (value) => _updateServerSettings(),
        ),

        const SizedBox(height: 16),

        // Port and HTTPS toggle
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  prefixIcon: Icon(Icons.settings_ethernet),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateServerSettings(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: SwitchListTile(
                title: const Text('Use HTTPS'),
                subtitle: const Text('Secure connection'),
                value: serverSettings.useHttps,
                onChanged: (value) {
                  _updateServerSettings(useHttps: value);
                  // Update port to default for protocol
                  if (value && _portController.text == '80') {
                    _portController.text = '443';
                  } else if (!value && _portController.text == '443') {
                    _portController.text = '80';
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // API Path
        TextField(
          controller: _apiPathController,
          decoration: const InputDecoration(
            labelText: 'API Path',
            hintText: '/zm/api',
            prefixIcon: Icon(Icons.api),
          ),
          onChanged: (value) => _updateServerSettings(),
        ),

        const SizedBox(height: 24),

        // Authentication section
        Text(
          'Authentication',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // Username
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person),
          ),
          onChanged: (value) => _updateServerSettings(),
        ),

        const SizedBox(height: 16),

        // Password
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
          onChanged: (value) => _updateServerSettings(),
        ),

        const SizedBox(height: 24),

        // Advanced settings
        ExpansionTile(
          title: const Text('Advanced Settings'),
          children: [
            // Connection timeout
            ListTile(
              title: const Text('Connection Timeout'),
              subtitle: Text('${serverSettings.connectionTimeout} seconds'),
              trailing: SizedBox(
                width: 100,
                child: Slider(
                  value: serverSettings.connectionTimeout.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: '${serverSettings.connectionTimeout}s',
                  onChanged: (value) => _updateServerSettings(
                    connectionTimeout: value.round(),
                  ),
                ),
              ),
            ),

            // SSL verification
            SwitchListTile(
              title: const Text('Verify SSL Certificate'),
              subtitle: const Text('Disable for self-signed certificates'),
              value: serverSettings.verifySSL,
              onChanged: (value) => _updateServerSettings(verifySSL: value),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _testConnection,
                icon: const Icon(Icons.wifi_find),
                label: const Text('Test Connection'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearSettings,
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
            ),
          ],
        ),

        // Connection status
        if (serverSettings.isConfigured) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Server Configured'),
                      Text(
                        serverSettings.fullUrl ?? 'Invalid URL',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Update server settings
  void _updateServerSettings({
    String? serverUrl,
    String? username,
    String? password,
    bool? useHttps,
    int? port,
    String? apiPath,
    int? connectionTimeout,
    bool? verifySSL,
  }) {
    final currentSettings = widget.settings.serverSettings;
    final updatedSettings = currentSettings.copyWith(
      serverUrl: serverUrl ?? _serverUrlController.text,
      username: username ?? _usernameController.text,
      password: password ?? _passwordController.text,
      useHttps: useHttps ?? currentSettings.useHttps,
      port: port ?? int.tryParse(_portController.text) ?? currentSettings.port,
      apiPath: apiPath ?? _apiPathController.text,
      connectionTimeout: connectionTimeout ?? currentSettings.connectionTimeout,
      verifySSL: verifySSL ?? currentSettings.verifySSL,
    );

    ref.read(appSettingsProvider.notifier).updateServerSettings(updatedSettings);
  }

  /// Test server connection
  void _testConnection() async {
    try {
      final success = await ref.read(appSettingsProvider.notifier).testServerConnection();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Connection successful!' : 'Connection failed'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Clear all server settings
  void _clearSettings() {
    _serverUrlController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _portController.text = '443';
    _apiPathController.text = '/zm/api';
    _updateServerSettings();
  }
}
