import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_settings_model.dart';
import '../providers/settings_providers.dart';

/// Security settings widget for app protection
/// Manages biometric authentication, PIN, and privacy settings
class SecuritySettingsWidget extends ConsumerWidget {
  final AppSettings settings;

  const SecuritySettingsWidget({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securitySettings = settings.securitySettings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Biometric authentication
        SwitchListTile(
          title: const Text('Biometric Authentication'),
          subtitle: const Text('Use fingerprint or face unlock'),
          value: securitySettings.biometricEnabled,
          onChanged: (value) => _updateSecuritySettings(
            ref,
            securitySettings.copyWith(biometricEnabled: value),
          ),
        ),

        const Divider(),

        // PIN authentication
        SwitchListTile(
          title: const Text('PIN Protection'),
          subtitle: const Text('Require PIN to access app'),
          value: securitySettings.pinEnabled,
          onChanged: (value) {
            if (value) {
              _showSetPinDialog(context, ref, securitySettings);
            } else {
              _updateSecuritySettings(
                ref,
                securitySettings.copyWith(
                  pinEnabled: false,
                  pinCode: null,
                ),
              );
            }
          },
        ),

        // Change PIN (if enabled)
        if (securitySettings.pinEnabled)
          ListTile(
            title: const Text('Change PIN'),
            subtitle: const Text('Update your security PIN'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showChangePinDialog(context, ref, securitySettings),
          ),

        const Divider(),

        // Auto-lock timer
        ListTile(
          title: const Text('Auto-Lock'),
          subtitle: Text(
            securitySettings.autoLockMinutes == 0
                ? 'Never'
                : 'After ${securitySettings.autoLockMinutes} minutes',
          ),
          trailing: DropdownButton<int>(
            value: securitySettings.autoLockMinutes,
            onChanged: (value) {
              if (value != null) {
                _updateSecuritySettings(
                  ref,
                  securitySettings.copyWith(autoLockMinutes: value),
                );
              }
            },
            items: [0, 1, 2, 5, 10, 15, 30].map((minutes) {
              return DropdownMenuItem(
                value: minutes,
                child: Text(minutes == 0 ? 'Never' : '$minutes min'),
              );
            }).toList(),
          ),
        ),

        const Divider(),

        // Privacy settings
        SwitchListTile(
          title: const Text('Hide in Recent Apps'),
          subtitle: const Text('Blur app content in task switcher'),
          value: securitySettings.hideInRecents,
          onChanged: (value) => _updateSecuritySettings(
            ref,
            securitySettings.copyWith(hideInRecents: value),
          ),
        ),

        SwitchListTile(
          title: const Text('Allow Screenshots'),
          subtitle: const Text('Permit taking screenshots of the app'),
          value: securitySettings.allowScreenshots,
          onChanged: (value) => _updateSecuritySettings(
            ref,
            securitySettings.copyWith(allowScreenshots: value),
          ),
        ),

        const SizedBox(height: 24),

        // Security status
        Card(
          color: securitySettings.hasSecurityEnabled
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  securitySettings.hasSecurityEnabled
                      ? Icons.security
                      : Icons.security_outlined,
                  color: securitySettings.hasSecurityEnabled
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        securitySettings.hasSecurityEnabled
                            ? 'Security Enabled'
                            : 'Security Disabled',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        securitySettings.hasSecurityEnabled
                            ? 'Your app is protected'
                            : 'Consider enabling security features',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Update security settings
  void _updateSecuritySettings(
    WidgetRef ref,
    SecuritySettings settings,
  ) {
    ref.read(appSettingsProvider.notifier).updateSecuritySettings(settings);
  }

  /// Show set PIN dialog
  void _showSetPinDialog(
    BuildContext context,
    WidgetRef ref,
    SecuritySettings settings,
  ) {
    String pin = '';
    String confirmPin = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Security PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter PIN',
                  hintText: '4-6 digits',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                onChanged: (value) => setState(() => pin = value),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Confirm PIN',
                  hintText: 'Re-enter PIN',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                onChanged: (value) => setState(() => confirmPin = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: pin.length >= 4 && pin == confirmPin
                  ? () {
                      Navigator.pop(context);
                      _updateSecuritySettings(
                        ref,
                        settings.copyWith(
                          pinEnabled: true,
                          pinCode: pin,
                        ),
                      );
                    }
                  : null,
              child: const Text('Set PIN'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show change PIN dialog
  void _showChangePinDialog(
    BuildContext context,
    WidgetRef ref,
    SecuritySettings settings,
  ) {
    // String currentPin = ''; // Unused variable
    String newPin = '';
    String confirmPin = '';
    bool currentPinValid = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Security PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Current PIN',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                onChanged: (value) {
                  setState(() {
                    currentPinValid = value == settings.pinCode;
                  });
                },
              ),
              if (currentPinValid) ...[
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'New PIN',
                    hintText: '4-6 digits',
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  onChanged: (value) => setState(() => newPin = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Confirm New PIN',
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  onChanged: (value) => setState(() => confirmPin = value),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: currentPinValid &&
                      newPin.length >= 4 &&
                      newPin == confirmPin
                  ? () {
                      Navigator.pop(context);
                      _updateSecuritySettings(
                        ref,
                        settings.copyWith(pinCode: newPin),
                      );
                    }
                  : null,
              child: const Text('Change PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
