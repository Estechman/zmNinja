import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/interactive_timeline_widget.dart';
import '../widgets/timeline_navigation_widget.dart';
import '../providers/events_providers.dart';
import '../../domain/models/event_model.dart';
import '../../../home/presentation/providers/home_providers.dart';

/// Timeline screen for event visualization
/// Replicates original zmNinja's timeline functionality with interactive charts
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  DateTimeRange? _selectedDateRange;
  String? _selectedMonitor;

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);
    final cameras = ref.watch(camerasProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Events',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(eventsProvider),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      body: events.when(
        data: (eventList) => Stack(
          children: [
            InteractiveTimelineWidget(
              events: eventList,
              dateRange: _selectedDateRange,
              selectedMonitor: _selectedMonitor,
              onEventSelected: _onEventSelected,
            ),
            
            TimelineNavigationWidget(
              onZoomIn: () {
                // TODO: Connect to timeline zoom controls
              },
              onZoomOut: () {
                // TODO: Connect to timeline zoom controls
              },
              onFit: () {
                // TODO: Connect to timeline fit function
              },
            ),
          ],
        ),
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
                'Error loading events',
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
                onPressed: () => ref.invalidate(eventsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onEventSelected(EventModel event) {
    context.go('/event/${event.id}/player');
  }

  void _showFilterDialog() {
    final cameras = ref.read(camerasProvider).value ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Timeline'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Date Range'),
                subtitle: Text(_selectedDateRange != null 
                  ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                  : 'All dates'),
                trailing: const Icon(Icons.date_range),
                onTap: _selectDateRange,
              ),
              ListTile(
                title: const Text('Monitor'),
                subtitle: Text(_getMonitorName(cameras) ?? 'All monitors'),
                trailing: const Icon(Icons.videocam),
                onTap: () => _selectMonitor(cameras),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDateRange = null;
                          _selectedMonitor = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (dateRange != null) {
      setState(() {
        _selectedDateRange = dateRange;
      });
    }
  }

  void _selectMonitor(List cameras) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Monitor'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              ListTile(
                title: const Text('All Monitors'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: _selectedMonitor,
                  onChanged: (value) {
                    setState(() {
                      _selectedMonitor = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ...cameras.map((camera) => ListTile(
                title: Text(camera.name),
                subtitle: Text('Monitor ${camera.id}'),
                leading: Radio<String>(
                  value: camera.id,
                  groupValue: _selectedMonitor,
                  onChanged: (value) {
                    setState(() {
                      _selectedMonitor = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              )),
            ],
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timeline Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Timeline View',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Blue line shows total events per hour'),
              Text('• Red line shows alarm events per hour'),
              Text('• Click on timeline points to view event details'),
              Text('• Use zoom controls to adjust time scale'),
              Text('• Filter by date range and monitor'),
              SizedBox(height: 16),
              Text(
                'Navigation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Use arrow buttons to navigate days'),
              Text('• Click calendar icon to jump to specific date'),
              Text('• Click Play button to view event in player'),
              SizedBox(height: 16),
              Text(
                'Filters',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• "Alarm Frames Only" shows events with motion'),
              Text('• Monitor filter shows events from specific camera'),
              Text('• Date range filter limits timeline scope'),
            ],
          ),
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

  String? _getMonitorName(List cameras) {
    if (_selectedMonitor == null) return null;
    
    try {
      final camera = cameras.firstWhere((c) => c.id == _selectedMonitor);
      return camera.name;
    } catch (e) {
      return 'Monitor $_selectedMonitor';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
