import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/ptz_capabilities_model.dart';
import '../providers/ptz_providers.dart';

/// Enhanced PTZ controls widget with radial menu
/// Replicates original zmNinja's radial PTZ interface
class PtzControlsWidget extends ConsumerStatefulWidget {
  final String cameraId;
  final PtzCapabilities capabilities;

  const PtzControlsWidget({
    super.key,
    required this.cameraId,
    required this.capabilities,
  });

  @override
  ConsumerState<PtzControlsWidget> createState() => _PtzControlsWidgetState();
}

class _PtzControlsWidgetState extends ConsumerState<PtzControlsWidget> {
  bool _showRadialMenu = true;
  bool _showPresets = false;

  @override
  Widget build(BuildContext context) {
    final isControlling = ref.watch(ptzControllingProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Radial'),
                  icon: Icon(Icons.radio_button_checked),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Grid'),
                  icon: Icon(Icons.grid_view),
                ),
              ],
              selected: {_showRadialMenu},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _showRadialMenu = selection.first;
                });
              },
            ),
          ],
        ),
        
        const SizedBox(height: 24),

        // Movement controls
        if (widget.capabilities.canMove) ...[
          Text(
            'Movement Controls',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          _showRadialMenu ? _buildRadialPtzMenu() : _buildGridPtzMenu(),
        ],

        const SizedBox(height: 24),

        // Zoom controls
        if (widget.capabilities.canZoom) ...[
          Text(
            'Zoom Controls',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: isControlling ? null : () => _zoom(ref, PtzZoomDirection.zoomOut),
                icon: const Icon(Icons.zoom_out),
                label: const Text('Zoom Out'),
              ),
              ElevatedButton.icon(
                onPressed: isControlling ? null : () => _zoom(ref, PtzZoomDirection.zoomIn),
                icon: const Icon(Icons.zoom_in),
                label: const Text('Zoom In'),
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),

        // Additional controls
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.capabilities.canHome)
              ElevatedButton.icon(
                onPressed: isControlling ? null : () => _goHome(ref),
                icon: const Icon(Icons.home),
                label: const Text('Home'),
              ),
            
            if (widget.capabilities.canReset)
              ElevatedButton.icon(
                onPressed: isControlling ? null : () => _calibrate(ref),
                icon: const Icon(Icons.tune),
                label: const Text('Calibrate'),
              ),
            
            ElevatedButton.icon(
              onPressed: () => _stopAll(ref),
              icon: const Icon(Icons.stop),
              label: const Text('Stop All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showPresets = !_showPresets;
                });
              },
              icon: Icon(_showPresets ? Icons.visibility_off : Icons.visibility),
              label: const Text('Presets'),
            ),
          ],
        ),
        
        if (_showPresets) ...[
          const SizedBox(height: 16),
          _buildPresetsOverlay(),
        ],
      ],
    );
  }

  /// Build radial PTZ menu matching original zmNinja design
  Widget _buildRadialPtzMenu() {
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        children: [
          // Center control button
          Positioned(
            top: 125,
            left: 125,
            child: GestureDetector(
              onTap: () => _stop(ref),
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stop, color: Colors.white),
              ),
            ),
          ),
          
          // Radial direction buttons
          ..._buildRadialButtons(),
        ],
      ),
    );
  }

  List<Widget> _buildRadialButtons() {
    final directions = [
      {'angle': -90, 'direction': PtzDirection.up, 'icon': Icons.keyboard_arrow_up},
      {'angle': -45, 'direction': PtzDirection.upRight, 'icon': Icons.north_east},
      {'angle': 0, 'direction': PtzDirection.right, 'icon': Icons.keyboard_arrow_right},
      {'angle': 45, 'direction': PtzDirection.downRight, 'icon': Icons.south_east},
      {'angle': 90, 'direction': PtzDirection.down, 'icon': Icons.keyboard_arrow_down},
      {'angle': 135, 'direction': PtzDirection.downLeft, 'icon': Icons.south_west},
      {'angle': 180, 'direction': PtzDirection.left, 'icon': Icons.keyboard_arrow_left},
      {'angle': -135, 'direction': PtzDirection.upLeft, 'icon': Icons.north_west},
    ];

    return directions.map((dir) {
      final angle = (dir['angle'] as int) * (pi / 180);
      final radius = 100.0;
      final x = 150 + radius * cos(angle) - 25;
      final y = 150 + radius * sin(angle) - 25;

      return Positioned(
        left: x,
        top: y,
        child: _RadialButton(
          icon: dir['icon'] as IconData,
          onPressed: () => _move(ref, dir['direction'] as PtzDirection),
        ),
      );
    }).toList();
  }

  Widget _buildGridPtzMenu() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          // Up
          Positioned(
            top: 0,
            left: 70,
            child: _DirectionalButton(
              icon: Icons.keyboard_arrow_up,
              onPressed: () => _move(ref, PtzDirection.up),
            ),
          ),
          
          // Down
          Positioned(
            bottom: 0,
            left: 70,
            child: _DirectionalButton(
              icon: Icons.keyboard_arrow_down,
              onPressed: () => _move(ref, PtzDirection.down),
            ),
          ),
          
          // Left
          Positioned(
            left: 0,
            top: 70,
            child: _DirectionalButton(
              icon: Icons.keyboard_arrow_left,
              onPressed: () => _move(ref, PtzDirection.left),
            ),
          ),
          
          // Right
          Positioned(
            right: 0,
            top: 70,
            child: _DirectionalButton(
              icon: Icons.keyboard_arrow_right,
              onPressed: () => _move(ref, PtzDirection.right),
            ),
          ),
          
          // Up-Left
          Positioned(
            top: 20,
            left: 20,
            child: _DirectionalButton(
              icon: Icons.north_west,
              onPressed: () => _move(ref, PtzDirection.upLeft),
              size: 40,
            ),
          ),
          
          // Up-Right
          Positioned(
            top: 20,
            right: 20,
            child: _DirectionalButton(
              icon: Icons.north_east,
              onPressed: () => _move(ref, PtzDirection.upRight),
              size: 40,
            ),
          ),
          
          // Down-Left
          Positioned(
            bottom: 20,
            left: 20,
            child: _DirectionalButton(
              icon: Icons.south_west,
              onPressed: () => _move(ref, PtzDirection.downLeft),
              size: 40,
            ),
          ),
          
          // Down-Right
          Positioned(
            bottom: 20,
            right: 20,
            child: _DirectionalButton(
              icon: Icons.south_east,
              onPressed: () => _move(ref, PtzDirection.downRight),
              size: 40,
            ),
          ),
          
          // Center stop button
          Positioned(
            top: 70,
            left: 70,
            child: _DirectionalButton(
              icon: Icons.stop,
              onPressed: () => _stop(ref),
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsOverlay() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PTZ Presets',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _showAddPresetDialog,
                tooltip: 'Add Preset',
              ),
            ],
          ),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildPresetButton(index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(int presetNumber) {
    return ElevatedButton(
      onPressed: () => _recallPreset(presetNumber),
      onLongPress: () => _savePreset(presetNumber),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$presetNumber',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Preset',
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  /// Move camera in specified direction
  void _move(WidgetRef ref, PtzDirection direction) {
    ref.read(ptzControllerProvider(widget.cameraId).notifier).move(direction);
  }

  /// Stop camera movement
  void _stop(WidgetRef ref) {
    ref.read(ptzControllerProvider(widget.cameraId).notifier).stop();
  }

  /// Zoom camera
  void _zoom(WidgetRef ref, PtzZoomDirection direction) {
    ref.read(ptzControllerProvider(widget.cameraId).notifier).zoom(direction);
  }

  /// Go to home position
  void _goHome(WidgetRef ref) {
    ref.read(ptzControllerProvider(widget.cameraId).notifier).goHome();
  }

  /// Calibrate PTZ
  void _calibrate(WidgetRef ref) {
    ref.read(ptzControllerProvider(widget.cameraId).notifier).calibrate();
  }

  /// Stop all PTZ operations
  void _stopAll(WidgetRef ref) {
    ref.read(ptzControllerProvider(widget.cameraId).notifier).stopAll();
  }

  /// Recall PTZ preset
  void _recallPreset(int presetNumber) {
    ref.read(ptzControllerProvider(widget.cameraId).notifier).goToPreset(presetNumber);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Moving to preset $presetNumber')),
    );
  }

  /// Save current position as preset
  void _savePreset(int presetNumber) {
    ref.read(ptzControllerProvider(widget.cameraId).notifier).savePreset(presetNumber, 'Preset $presetNumber');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved current position as preset $presetNumber')),
    );
  }

  /// Show add preset dialog
  void _showAddPresetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add PTZ Preset'),
        content: const Text('Long press on a preset button to save the current camera position.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Individual directional button widget
class _DirectionalButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const _DirectionalButton({
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Icon(
          icon,
          size: size * 0.4,
          color: color != null ? Colors.white : null,
        ),
      ),
    );
  }
}

/// Radial button widget for circular PTZ menu
class _RadialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  const _RadialButton({
    required this.icon,
    this.onPressed,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: Icon(
          icon,
          size: size * 0.4,
        ),
      ),
    );
  }
}
