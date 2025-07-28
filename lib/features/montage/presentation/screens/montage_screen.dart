import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../home/domain/models/camera_model.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/presentation/widgets/camera_tile_widget.dart';
import '../../domain/models/montage_profile_model.dart';
import '../providers/montage_providers.dart';

class MontageScreen extends ConsumerStatefulWidget {
  const MontageScreen({super.key});

  @override
  ConsumerState<MontageScreen> createState() => _MontageScreenState();
}

class _MontageScreenState extends ConsumerState<MontageScreen> {
  final GlobalKey _gridKey = GlobalKey();
  bool _isDragMode = false;
  String _currentProfile = 'Default';

  @override
  Widget build(BuildContext context) {
    final cameras = ref.watch(camerasProvider);
    final cameraOrder = ref.watch(cameraOrderProvider);
    final currentProfile = ref.watch(currentMontageProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Montage - $currentProfile'),
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
            ],
          ),
        ],
      ),
      body: cameras.when(
        data: (cameraList) => _buildMontageGrid(cameraList, cameraOrder),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMontageGrid(List<CameraModel> cameras, List<String> cameraOrder) {
    final orderedCameras = _orderCameras(cameras, cameraOrder);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 840;
    
    int crossAxisCount;
    if (isDesktop) {
      crossAxisCount = cameras.length >= 4 ? 4 : cameras.length;
    } else if (screenSize.width > 600) {
      crossAxisCount = cameras.length >= 3 ? 3 : cameras.length;
    } else {
      crossAxisCount = cameras.length >= 2 ? 2 : 1;
    }

    if (_isDragMode) {
      return GridView.builder(
        key: _gridKey,
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 16 / 9,
        ),
        itemCount: orderedCameras.length,
        itemBuilder: (context, index) {
          final camera = orderedCameras[index];
          return _buildDraggableCameraTile(camera, index);
        },
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 16 / 9,
        ),
        itemCount: orderedCameras.length,
        itemBuilder: (context, index) {
          final camera = orderedCameras[index];
          return _buildCameraTile(camera);
        },
      );
    }
  }

  Widget _buildDraggableCameraTile(CameraModel camera, int index) {
    return Container(
      key: ValueKey(camera.id),
      child: Stack(
        children: [
          CameraTileWidget(camera: camera),
          if (_isDragMode)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.drag_handle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraTile(CameraModel camera) {
    return GestureDetector(
      onTap: () => context.go('/camera/${camera.id}'),
      onLongPress: () => _showCameraOptions(context, camera),
      child: CameraTileWidget(camera: camera),
    );
  }

  List<CameraModel> _orderCameras(List<CameraModel> cameras, List<String> order) {
    if (order.isEmpty) return cameras;
    
    final orderedCameras = <CameraModel>[];
    final cameraMap = {for (var camera in cameras) camera.id: camera};
    
    for (final cameraId in order) {
      final camera = cameraMap[cameraId];
      if (camera != null) {
        orderedCameras.add(camera);
        cameraMap.remove(cameraId);
      }
    }
    
    orderedCameras.addAll(cameraMap.values);
    return orderedCameras;
  }

  void _onReorder(int oldIndex, int newIndex) {
    // Note: StaggeredGridView doesn't have built-in reordering
    // This will be handled through drag gestures in drag mode
    ref.read(cameraOrderProvider.notifier).reorderCamera(oldIndex, newIndex);
  }

  void _toggleDragMode() {
    setState(() {
      _isDragMode = !_isDragMode;
    });
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
    }
  }

  void _showSaveProfileDialog() {
    final controller = TextEditingController(text: _currentProfile);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Profile'),
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
              _saveCurrentProfile(controller.text);
              Navigator.pop(context);
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
        title: const Text('Load Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return ListTile(
                title: Text(profile.name),
                subtitle: Text('Created: ${profile.createdAt.toString().split(' ')[0]}'),
                onTap: () {
                  _loadProfile(profile);
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
        title: const Text('Delete Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              if (profile.id == 'default') return const SizedBox.shrink();
              
              return ListTile(
                title: Text(profile.name),
                subtitle: Text('Created: ${profile.createdAt.toString().split(' ')[0]}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref.read(montageProfilesProvider.notifier).deleteProfile(profile.id);
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

  void _saveCurrentProfile(String name) {
    final cameraOrder = ref.read(cameraOrderProvider);
    final cameras = ref.read(camerasProvider).value ?? [];
    
    final layouts = cameras.map((camera) {
      final index = cameraOrder.indexOf(camera.id);
      return CameraLayout(
        cameraId: camera.id,
        x: (index % 4) * 25.0,
        y: (index ~/ 4) * 25.0,
        width: 25.0,
        height: 25.0,
        visible: true,
      );
    }).toList();

    final profile = MontageProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      cameraLayouts: layouts,
      createdAt: DateTime.now(),
    );

    ref.read(montageProfilesProvider.notifier).saveProfile(profile);
    ref.read(currentMontageProfileProvider.notifier).state = name;
    setState(() {
      _currentProfile = name;
    });
  }

  void _loadProfile(MontageProfile profile) {
    final newOrder = profile.cameraLayouts
        .where((layout) => layout.visible)
        .map((layout) => layout.cameraId)
        .toList();
    
    ref.read(cameraOrderProvider.notifier).updateOrder(newOrder);
    ref.read(currentMontageProfileProvider.notifier).state = profile.name;
    setState(() {
      _currentProfile = profile.name;
    });
  }

  void _showCameraOptions(BuildContext context, CameraModel camera) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('View Camera'),
            onTap: () {
              Navigator.pop(context);
              context.go('/camera/${camera.id}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.control_camera),
            title: const Text('PTZ Controls'),
            onTap: () {
              Navigator.pop(context);
              context.go('/ptz/${camera.id}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('View Events'),
            onTap: () {
              Navigator.pop(context);
              context.go('/events?camera=${camera.id}');
            },
          ),
        ],
      ),
    );
  }
}
