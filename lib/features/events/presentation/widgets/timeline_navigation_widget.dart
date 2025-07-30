import 'package:flutter/material.dart';

/// Timeline navigation widget with radial menu controls
/// Replicates original zmNinja's radial menu functionality
class TimelineNavigationWidget extends StatefulWidget {
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFit;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;

  const TimelineNavigationWidget({
    super.key,
    this.onZoomIn,
    this.onZoomOut,
    this.onFit,
    this.onMoveLeft,
    this.onMoveRight,
  });

  @override
  State<TimelineNavigationWidget> createState() => _TimelineNavigationWidgetState();
}

class _TimelineNavigationWidgetState extends State<TimelineNavigationWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExpanded) ..._buildExpandedControls(),
          
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            backgroundColor: const Color(0xFF982112),
            child: Icon(
              _isExpanded ? Icons.close : Icons.control_camera,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpandedControls() {
    return [
      _buildControlButton(
        icon: Icons.remove_circle,
        onPressed: widget.onZoomOut,
        tooltip: 'Zoom Out',
      ),
      
      const SizedBox(height: 8),
      
      _buildControlButton(
        icon: Icons.chevron_left,
        onPressed: widget.onMoveLeft,
        tooltip: 'Move Left',
      ),
      
      const SizedBox(height: 8),
      
      _buildControlButton(
        icon: Icons.fit_screen,
        onPressed: widget.onFit,
        tooltip: 'Fit Timeline',
      ),
      
      const SizedBox(height: 8),
      
      _buildControlButton(
        icon: Icons.chevron_right,
        onPressed: widget.onMoveRight,
        tooltip: 'Move Right',
      ),
      
      const SizedBox(height: 8),
      
      _buildControlButton(
        icon: Icons.add_circle,
        onPressed: widget.onZoomIn,
        tooltip: 'Zoom In',
      ),
      
      const SizedBox(height: 8),
    ];
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF982112),
      tooltip: tooltip,
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
