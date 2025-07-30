import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reorderables/reorderables.dart';
import '../../../home/domain/models/camera_model.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/presentation/widgets/camera_tile_widget.dart';
import '../providers/montage_providers.dart';
import '../../domain/models/montage_profile_model.dart';

/// Enhanced montage screen with drag-and-drop layouts
/// Replicates original zmNinja's Packery.js functionality
class EnhancedMontageScreen extends ConsumerStatefulWidget {
  const EnhancedMontageScreen({super.key});

  @override
  ConsumerState<EnhancedMontageScreen> createState() => _EnhancedMontageScreenState();
}

class _EnhancedMontageScreenState extends ConsumerState<EnhancedMontageScreen> {
  final GlobalKey _wrapKey = GlobalKey();
  bool _isDragMode = false;
  String _currentProfile = 'Default';

  @override
  Widget build(BuildContext context) {
    final cameras = ref.watch(camerasProvider);
    final currentProfileName = ref.watch(currentMontageProfileProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Montage - $_currentProfile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: Icon(_isDragMode ? Icons.check : Icons.drag_handle),
            onPressed: _toggleDragMode,
            tooltip: _isDragMode ? 'Save Layout' : 'Reorder Cameras',
          ),
          PopupMenuButton<String>(
            onSelected: _handleProfileAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'save', child: Text('Save Profile')),
              const PopupMenuItem(value: 'load', child: Text('Load Profile')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Profile')),
              const PopupMenuItem(value: 'new', child: Text('New Profile')),
            ],
          ),
        ],
      ),
      body: cameras.when(
        data: (cameraList) => _buildMontageGrid(cameraList),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading cameras',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(camerasProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isDragMode ? null : FloatingActionButton(
        onPressed: _showMontageSettings,
        tooltip: 'Montage Settings',
        child: const Icon(Icons.settings),
      ),
    );
  }

  Widget _buildMontageGrid(List<CameraModel> cameras) {
    if (cameras.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No cameras available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your ZoneMinder server connection',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_isDragMode) {
      return _buildDraggableGrid(cameras);
    } else {
      return _buildStaticGrid(cameras);
    }
  }

  Widget _buildDraggableGrid(List<CameraModel> cameras) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: ReorderableWrap(
        key: _wrapKey,
        spacing: 8,
        runSpacing: 8,
        children: cameras.map((camera) => _buildDraggableCameraTile(camera)).toList(),
        onReorder: _onReorderCameras,
        buildDraggableFeedback: (context, constraints, child) {
          return Transform.scale(
            scale: 1.1,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaticGrid(List<CameraModel> cameras) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 16 / 9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final camera = cameras[index];
                return GestureDetector(
                  onTap: () => _onCameraTap(camera),
                  onLongPress: () => _onCameraLongPress(camera),
                  child: CameraTileWidget(camera: camera),
                );
              },
              childCount: cameras.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableCameraTile(CameraModel camera) {
    final screenSize = MediaQuery.of(context).size;
    final tileWidth = (screenSize.width - 32) / 2 - 8;
    final tileHeight = tileWidth / (16 / 9);

    return SizedBox(
      width: tileWidth,
      height: tileHeight,
      child: Stack(
        children: [
          CameraTileWidget(camera: camera),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.drag_indicator,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _toggleDragMode() {
    setState(() {
      _isDragMode = !_isDragMode;
    });

    if (!_isDragMode) {
      _saveMontageLayout();
    }
  }

  void _onReorderCameras(int oldIndex, int newIndex) {
    // Handle camera reordering logic
    final cameras = ref.read(camerasProvider).value;
    if (cameras != null && oldIndex < cameras.length && newIndex < cameras.length) {
      // Update montage profile with new camera order
      ref.read(montageProfilesProvider.notifier).updateCameraOrder(
        _currentProfile,
        oldIndex,
        newIndex,
      );
    }
  }

  void _onCameraTap(CameraModel camera) {
    // Navigate to camera detail view using GoRouter
    context.go('/camera/${camera.id}');
  }

  void _onCameraLongPress(CameraModel camera) {
    _showCameraOptions(camera);
  }

  void _showCameraOptions(CameraModel camera) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(camera.name),
              subtitle: Text('Camera ${camera.id}'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Live Stream'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camera/${camera.id}');
              },
            ),
            if (camera.hasPtz)
              ListTile(
                leading: const Icon(Icons.control_camera),
                title: const Text('PTZ Controls'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/ptz/${camera.id}');
                },
              ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('View Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/events?camera=${camera.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Camera Settings'),
              onTap: () {
                Navigator.pop(context);
                _showCameraSettings(camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCameraSettings(CameraModel camera) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${camera.name} Settings'),
        content: const Text('Camera settings coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleProfileAction(String action) {
    switch (action) {
      case 'save':
        _showSaveProfileDialog();
        break;
      case 'load':
        _showLoadProfileDialog();
        break;
      case 'delete':
        _showDeleteProfileDialog();
        break;
      case 'new':
        _showNewProfileDialog();
        break;
    }
  }

  void _showSaveProfileDialog() {
    final controller = TextEditingController(text: _currentProfile);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Montage Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Profile Name',
            hintText: 'Enter profile name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final profileName = controller.text.trim();
              if (profileName.isNotEmpty) {
                _saveMontageProfile(profileName);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLoadProfileDialog() {
    final profiles = ref.read(montageProfilesProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Montage Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return ListTile(
                title: Text(profile.name),
                subtitle: Text('${profile.cameraLayouts.length} cameras'),
                trailing: Text(_formatDate(profile.createdAt)),
                onTap: () {
                  _loadMontageProfile(profile);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteProfileDialog() {
    final profiles = ref.read(montageProfilesProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Montage Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return ListTile(
                title: Text(profile.name),
                subtitle: Text('${profile.cameraLayouts.length} cameras'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteMontageProfile(profile);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showNewProfileDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Montage Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Profile Name',
            hintText: 'Enter new profile name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final profileName = controller.text.trim();
              if (profileName.isNotEmpty) {
                _createNewProfile(profileName);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showMontageSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Montage Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Auto-refresh'),
              subtitle: const Text('Automatically refresh camera feeds'),
              value: true, // TODO: Get from settings
              onChanged: (value) {
                // TODO: Update settings
              },
            ),
            ListTile(
              title: const Text('Refresh Interval'),
              subtitle: const Text('5 seconds'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show refresh interval picker
              },
            ),
            ListTile(
              title: const Text('Grid Layout'),
              subtitle: const Text('2 columns'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show grid layout options
              },
            ),
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

  void _saveMontageLayout() {
    // Save current layout to profile
    ref.read(montageProfilesProvider.notifier).saveCurrentLayout(_currentProfile);
  }

  void _saveMontageProfile(String profileName) {
    setState(() {
      _currentProfile = profileName;
    });
    ref.read(montageProfilesProvider.notifier).saveCurrentLayout(profileName);
  }

  void _loadMontageProfile(MontageProfile profile) {
    setState(() {
      _currentProfile = profile.name;
    });
    ref.read(montageProfilesProvider.notifier).loadProfile(profile);
  }

  void _deleteMontageProfile(MontageProfile profile) {
    ref.read(montageProfilesProvider.notifier).deleteProfile(profile.id);
  }

  void _createNewProfile(String profileName) {
    setState(() {
      _currentProfile = profileName;
    });
    ref.read(montageProfilesProvider.notifier).createNewProfile(profileName);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
