import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../domain/models/ptz_capabilities_model.dart';
import '../../domain/models/ptz_preset_model.dart';
import '../providers/ptz_providers.dart';

/// Radial PTZ controls widget matching original zmNinja design
/// Replicates the radial menu functionality from MonitorModalCtrl.js
class RadialPtzControlsWidget extends ConsumerStatefulWidget {
  final String cameraId;
  final PtzCapabilities capabilities;

  const RadialPtzControlsWidget({
    super.key,
    required this.cameraId,
    required this.capabilities,
  });

  @override
  ConsumerState<RadialPtzControlsWidget> createState() => _RadialPtzControlsWidgetState();
}

class _RadialPtzControlsWidgetState extends ConsumerState<RadialPtzControlsWidget>
    with TickerProviderStateMixin {
  bool _showPresets = false;
  bool _isMoving = false;
  String? _currentDirection;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presets = ref.watch(ptzPresetsProvider(widget.cameraId));
    
    return Container(
      width: 350,
      height: 350,
      child: Stack(
        children: [
          // Background circle
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          
          // Center stop button
          Positioned(
            top: 150,
            left: 150,
            child: GestureDetector(
              onTap: _stopMovement,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isMoving ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isMoving 
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isMoving 
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary).withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isMoving ? Icons.stop : Icons.my_location,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Directional buttons
          ..._buildDirectionalButtons(),
          
          // Zoom controls
          if (widget.capabilities.canZoom) ..._buildZoomControls(),
          
          // Preset overlay
          if (_showPresets) _buildPresetOverlay(presets),
          
          // Control panel
          _buildControlPanel(),
        ],
      ),
    );
  }

  List<Widget> _buildDirectionalButtons() {
    final directions = [
      {'angle': -90, 'direction': 'up', 'icon': Icons.keyboard_arrow_up},
      {'angle': -45, 'direction': 'up-right', 'icon': Icons.north_east},
      {'angle': 0, 'direction': 'right', 'icon': Icons.keyboard_arrow_right},
      {'angle': 45, 'direction': 'down-right', 'icon': Icons.south_east},
      {'angle': 90, 'direction': 'down', 'icon': Icons.keyboard_arrow_down},
      {'angle': 135, 'direction': 'down-left', 'icon': Icons.south_west},
      {'angle': 180, 'direction': 'left', 'icon': Icons.keyboard_arrow_left},
      {'angle': -135, 'direction': 'up-left', 'icon': Icons.north_west},
    ];

    return directions.map((dir) {
      final angle = (dir['angle'] as int) * (math.pi / 180);
      final radius = 120.0;
      final x = 175 + radius * math.cos(angle) - 25;
      final y = 175 + radius * math.sin(angle) - 25;
      final direction = dir['direction'] as String;
      final isActive = _currentDirection == direction;

      return Positioned(
        left: x,
        top: y,
        child: GestureDetector(
          onTapDown: (_) => _startMovement(direction),
          onTapUp: (_) => _stopMovement(),
          onTapCancel: _stopMovement,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: isActive ? 2 : 1,
              ),
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Icon(
              dir['icon'] as IconData,
              color: isActive 
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildZoomControls() {
    return [
      // Zoom In
      Positioned(
        top: 50,
        left: 150,
        child: _buildZoomButton(
          icon: Icons.zoom_in,
          onPressed: () => _zoom('in'),
          tooltip: 'Zoom In',
        ),
      ),
      // Zoom Out
      Positioned(
        bottom: 50,
        left: 150,
        child: _buildZoomButton(
          icon: Icons.zoom_out,
          onPressed: () => _zoom('out'),
          tooltip: 'Zoom Out',
        ),
      ),
    ];
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPresetOverlay(AsyncValue<List<PtzPreset>> presets) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        ),
        child: presets.when(
          data: (presetList) => _buildPresetGrid(presetList),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 8),
                Text(
                  'Error loading presets',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetGrid(List<PtzPreset> presets) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Text(
            'PTZ Presets',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: math.min(presets.length, 9),
              itemBuilder: (context, index) {
                final preset = presets[index];
                return GestureDetector(
                  onTap: () => _gotoPreset(preset),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${preset.position}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _showPresets = false),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      bottom: 10,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: Icons.bookmark,
              label: 'Presets',
              onPressed: () => setState(() => _showPresets = !_showPresets),
              isActive: _showPresets,
            ),
            _buildControlButton(
              icon: Icons.home,
              label: 'Home',
              onPressed: _gotoHome,
            ),
            _buildControlButton(
              icon: Icons.refresh,
              label: 'Reset',
              onPressed: _resetPosition,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startMovement(String direction) {
    setState(() {
      _isMoving = true;
      _currentDirection = direction;
    });
    
    // Send PTZ command
    // Convert string direction to PtzDirection enum
    PtzDirection ptzDir;
    switch (direction) {
      case 'up': ptzDir = PtzDirection.up; break;
      case 'down': ptzDir = PtzDirection.down; break;
      case 'left': ptzDir = PtzDirection.left; break;
      case 'right': ptzDir = PtzDirection.right; break;
      case 'up-left': ptzDir = PtzDirection.upLeft; break;
      case 'up-right': ptzDir = PtzDirection.upRight; break;
      case 'down-left': ptzDir = PtzDirection.downLeft; break;
      case 'down-right': ptzDir = PtzDirection.downRight; break;
      default: ptzDir = PtzDirection.up;
    }
    ref.read(ptzControllerProvider(widget.cameraId).notifier).move(ptzDir);
  }

  void _stopMovement() {
    setState(() {
      _isMoving = false;
      _currentDirection = null;
    });
    
    // Send stop command
    ref.read(ptzControllerProvider(widget.cameraId).notifier).stop();
  }

  void _zoom(String direction) {
    // Convert string direction to PtzZoomDirection enum
    final zoomDir = direction == 'in' ? PtzZoomDirection.zoomIn : PtzZoomDirection.zoomOut;
    ref.read(ptzControllerProvider(widget.cameraId).notifier).zoom(zoomDir);
  }

  void _gotoPreset(PtzPreset preset) {
    setState(() => _showPresets = false);
    ref.read(ptzControllerProvider(widget.cameraId).notifier).goToPreset(preset.id);
  }

  void _gotoHome() {
    ref.read(ptzControllerProvider(widget.cameraId).notifier).goHome();
  }

  void _resetPosition() {
    ref.read(ptzControllerProvider(widget.cameraId).notifier).stopAll();
  }
}
