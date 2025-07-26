import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_settings_model.dart';
import '../providers/settings_providers.dart';

/// Display settings widget for UI and visual preferences
/// Manages theme, text scale, grid layout, and video quality
class DisplaySettingsWidget extends ConsumerWidget {
  final AppSettings settings;

  const DisplaySettingsWidget({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displaySettings = settings.displaySettings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Theme mode
        ListTile(
          title: const Text('Theme'),
          subtitle: Text('Current: ${_getThemeName(displaySettings.themeMode)}'),
          trailing: DropdownButton<AppThemeMode>(
            value: displaySettings.themeMode,
            onChanged: (value) {
              if (value != null) {
                _updateDisplaySettings(
                  ref,
                  displaySettings.copyWith(themeMode: value),
                );
              }
            },
            items: AppThemeMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(_getThemeName(mode)),
              );
            }).toList(),
          ),
        ),

        const Divider(),

        // Text scale
        ListTile(
          title: const Text('Text Size'),
          subtitle: Text('Scale: ${(displaySettings.textScale * 100).round()}%'),
          trailing: SizedBox(
            width: 150,
            child: Slider(
              value: displaySettings.textScale,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: '${(displaySettings.textScale * 100).round()}%',
              onChanged: (value) => _updateDisplaySettings(
                ref,
                displaySettings.copyWith(textScale: value),
              ),
            ),
          ),
        ),

        const Divider(),

        // Grid layout
        ListTile(
          title: const Text('Default Grid Layout'),
          subtitle: Text('Current: ${_getGridLayoutName(displaySettings.defaultGridLayout)}'),
          trailing: DropdownButton<GridLayout>(
            value: displaySettings.defaultGridLayout,
            onChanged: (value) {
              if (value != null) {
                _updateDisplaySettings(
                  ref,
                  displaySettings.copyWith(defaultGridLayout: value),
                );
              }
            },
            items: GridLayout.values.map((layout) {
              return DropdownMenuItem(
                value: layout,
                child: Text(_getGridLayoutName(layout)),
              );
            }).toList(),
          ),
        ),

        const Divider(),

        // Video quality
        ListTile(
          title: const Text('Stream Quality'),
          subtitle: Text('Current: ${_getVideoQualityName(displaySettings.streamQuality)}'),
          trailing: DropdownButton<VideoQuality>(
            value: displaySettings.streamQuality,
            onChanged: (value) {
              if (value != null) {
                _updateDisplaySettings(
                  ref,
                  displaySettings.copyWith(streamQuality: value),
                );
              }
            },
            items: VideoQuality.values.map((quality) {
              return DropdownMenuItem(
                value: quality,
                child: Text(_getVideoQualityName(quality)),
              );
            }).toList(),
          ),
        ),

        const Divider(),

        // Display options
        SwitchListTile(
          title: const Text('Show Camera Names'),
          subtitle: const Text('Display camera names on tiles'),
          value: displaySettings.showCameraNames,
          onChanged: (value) => _updateDisplaySettings(
            ref,
            displaySettings.copyWith(showCameraNames: value),
          ),
        ),

        SwitchListTile(
          title: const Text('Show Timestamps'),
          subtitle: const Text('Display timestamps on video feeds'),
          value: displaySettings.showTimestamps,
          onChanged: (value) => _updateDisplaySettings(
            ref,
            displaySettings.copyWith(showTimestamps: value),
          ),
        ),

        SwitchListTile(
          title: const Text('Keep Screen On'),
          subtitle: const Text('Prevent screen from turning off'),
          value: displaySettings.keepScreenOn,
          onChanged: (value) => _updateDisplaySettings(
            ref,
            displaySettings.copyWith(keepScreenOn: value),
          ),
        ),

        const SizedBox(height: 16),

        // Preview section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                
                // Sample camera tile preview
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Mock video feed
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[200]!, Colors.blue[400]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.videocam,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      // Camera name overlay
                      if (displaySettings.showCameraNames)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Front Door',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10 * displaySettings.textScale,
                              ),
                            ),
                          ),
                        ),
                      
                      // Timestamp overlay
                      if (displaySettings.showTimestamps)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '12:34:56',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10 * displaySettings.textScale,
                              ),
                            ),
                          ),
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

  /// Update display settings
  void _updateDisplaySettings(
    WidgetRef ref,
    DisplaySettings settings,
  ) {
    ref.read(appSettingsProvider.notifier).updateDisplaySettings(settings);
  }

  /// Get theme name for display
  String _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  /// Get grid layout name for display
  String _getGridLayoutName(GridLayout layout) {
    switch (layout) {
      case GridLayout.auto:
        return 'Auto';
      case GridLayout.single:
        return 'Single';
      case GridLayout.quad:
        return '2x2 (4 cameras)';
      case GridLayout.nine:
        return '3x3 (9 cameras)';
      case GridLayout.sixteen:
        return '4x4 (16 cameras)';
    }
  }

  /// Get video quality name for display
  String _getVideoQualityName(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.low:
        return 'Low (480p)';
      case VideoQuality.medium:
        return 'Medium (720p)';
      case VideoQuality.high:
        return 'High (1080p)';
      case VideoQuality.ultra:
        return 'Ultra (4K)';
    }
  }
}
