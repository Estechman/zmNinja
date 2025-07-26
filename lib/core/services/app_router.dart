import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/camera_detail/presentation/screens/camera_detail_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/ptz/presentation/screens/ptz_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/logs/presentation/screens/logs_screen.dart';

/// App router provider using GoRouter for navigation
/// Manages all route definitions and navigation logic for zmNinja
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      // Home route - Main dashboard with montage view
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Camera detail route - Individual camera view with controls
      GoRoute(
        path: '/camera/:cameraId',
        name: 'camera_detail',
        builder: (context, state) {
          final cameraId = state.pathParameters['cameraId']!;
          return CameraDetailScreen(cameraId: cameraId);
        },
      ),
      
      // Events route - Browse recorded events and timeline
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsScreen(),
      ),
      
      // Event detail route - Individual event viewing with video playback
      GoRoute(
        path: '/event/:eventId',
        name: 'event_detail',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),
      
      // PTZ control route - Pan/Tilt/Zoom camera controls
      GoRoute(
        path: '/ptz/:cameraId',
        name: 'ptz',
        builder: (context, state) {
          final cameraId = state.pathParameters['cameraId']!;
          return PtzScreen(cameraId: cameraId);
        },
      ),
      
      // Settings route - App configuration and preferences
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // Logs route - System logs and debugging information
      GoRoute(
        path: '/logs',
        name: 'logs',
        builder: (context, state) => const LogsScreen(),
      ),
    ],
    
    // Error handling for unknown routes
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Route not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
