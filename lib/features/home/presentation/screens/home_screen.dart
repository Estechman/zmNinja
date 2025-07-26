import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/home_providers.dart';
import '../widgets/camera_grid_widget.dart';
import '../widgets/navigation_drawer_widget.dart';

/// Home screen displaying camera montage view
/// Main dashboard for zmNinja with live camera feeds
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameras = ref.watch(camerasProvider);
    final connectionStatus = ref.watch(connectionStatusProvider);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('zmNinja'),
        actions: [
          // Connection status indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  connectionStatus.isUnknown 
                    ? Icons.wifi 
                    : connectionStatus.isConnected 
                      ? Icons.wifi 
                      : Icons.wifi_off,
                  color: connectionStatus.isUnknown 
                    ? Colors.orange 
                    : connectionStatus.isConnected 
                      ? Colors.green 
                      : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  connectionStatus.isUnknown 
                    ? 'Connecting...' 
                    : connectionStatus.isConnected 
                      ? 'Connected' 
                      : 'Offline',
                  style: TextStyle(
                    color: connectionStatus.isUnknown 
                      ? Colors.orange 
                      : connectionStatus.isConnected 
                        ? Colors.green 
                        : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Quick actions for desktop
          if (isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.event),
              onPressed: () => context.go('/events'),
              tooltip: 'Events',
            ),
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () => context.go('/logs'),
              tooltip: 'Logs',
            ),
          ],
          
          // Settings navigation
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      
      // Navigation drawer for desktop/tablet layouts
      drawer: isDesktop ? const NavigationDrawerWidget() : null,
      
      body: cameras.when(
        data: (cameraList) {
          if (cameraList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_off, 
                    size: isDesktop ? 80 : 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cameras configured',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add cameras in Settings to start monitoring',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/settings'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Cameras'),
                  ),
                ],
              ),
            );
          }
          
          return Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) ...[
                  Text(
                    'Camera Montage',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${cameraList.length} cameras • ${cameraList.where((c) => c.isOnline).length} online',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Expanded(
                  child: CameraGridWidget(cameras: cameraList),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading cameras...'),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline, 
                size: isDesktop ? 80 : 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Connection Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to load cameras. Check your connection.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => ref.refresh(camerasProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/settings'),
                    icon: const Icon(Icons.settings),
                    label: const Text('Settings'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      
      // Floating action button for mobile/tablet
      floatingActionButton: !isDesktop ? FloatingActionButton(
        onPressed: () => context.go('/events'),
        tooltip: 'View Events',
        child: const Icon(Icons.event),
      ) : null,
    );
  }
}
