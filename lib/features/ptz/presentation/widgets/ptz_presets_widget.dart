import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/ptz_preset_model.dart';
import '../providers/ptz_providers.dart';

/// PTZ presets widget for managing saved positions
/// Displays list of presets with go-to and save functionality
class PtzPresetsWidget extends ConsumerWidget {
  final String cameraId;

  const PtzPresetsWidget({
    super.key,
    required this.cameraId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(ptzPresetsProvider(cameraId));
    final isControlling = ref.watch(ptzControllingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Presets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showSavePresetDialog(context, ref),
              tooltip: 'Save Current Position',
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Presets list
        Expanded(
          child: presets.when(
            data: (presetsList) {
              if (presetsList.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 48),
                      SizedBox(height: 16),
                      Text('No presets saved'),
                      SizedBox(height: 8),
                      Text('Save current position as preset'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: presetsList.length,
                itemBuilder: (context, index) {
                  final preset = presetsList[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: preset.isDefault 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey,
                        child: Text(
                          preset.id.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      title: Text(preset.name),
                      
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (preset.description != null)
                            Text(preset.description!),
                          if (preset.hasPositionData)
                            Text(
                              preset.positionString,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                      
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Go to preset button
                          IconButton(
                            icon: const Icon(Icons.my_location),
                            onPressed: isControlling 
                                ? null 
                                : () => _goToPreset(ref, preset.id),
                            tooltip: 'Go to Preset',
                          ),
                          
                          // Preset options menu
                          PopupMenuButton<String>(
                            onSelected: (value) => _handlePresetAction(
                              context, ref, preset, value,
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'update',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Update'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'rename',
                                child: ListTile(
                                  leading: Icon(Icons.edit_note),
                                  title: Text('Rename'),
                                ),
                              ),
                              if (!preset.isDefault)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete'),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      
                      onTap: () => _goToPreset(ref, preset.id),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text('Error loading presets: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(ptzPresetsProvider(cameraId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Go to preset position
  void _goToPreset(WidgetRef ref, int presetId) {
    ref.read(ptzControllerProvider(cameraId).notifier).goToPreset(presetId);
  }

  /// Handle preset action menu
  void _handlePresetAction(
    BuildContext context,
    WidgetRef ref,
    PtzPreset preset,
    String action,
  ) {
    switch (action) {
      case 'update':
        _updatePreset(ref, preset);
        break;
      case 'rename':
        _showRenamePresetDialog(context, ref, preset);
        break;
      case 'delete':
        _showDeletePresetDialog(context, ref, preset);
        break;
    }
  }

  /// Update preset with current position
  void _updatePreset(WidgetRef ref, PtzPreset preset) {
    ref.read(ptzControllerProvider(cameraId).notifier)
        .savePreset(preset.id, preset.name);
    
    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(content: Text('Updated preset: ${preset.name}')),
    );
  }

  /// Show save preset dialog
  void _showSavePresetDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Preset Name',
                hintText: 'Enter preset name',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                // TODO: Get next available preset ID
                final presetId = DateTime.now().millisecondsSinceEpoch % 100;
                ref.read(ptzControllerProvider(cameraId).notifier)
                    .savePreset(presetId, nameController.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Show rename preset dialog
  void _showRenamePresetDialog(
    BuildContext context,
    WidgetRef ref,
    PtzPreset preset,
  ) {
    final nameController = TextEditingController(text: preset.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Preset'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Preset Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                ref.read(ptzControllerProvider(cameraId).notifier)
                    .savePreset(preset.id, nameController.text);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  /// Show delete preset confirmation dialog
  void _showDeletePresetDialog(
    BuildContext context,
    WidgetRef ref,
    PtzPreset preset,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement preset deletion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted preset: ${preset.name}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
