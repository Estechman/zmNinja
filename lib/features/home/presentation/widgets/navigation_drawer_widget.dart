import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation drawer widget for app-wide navigation
/// Provides access to all main sections of zmNinja
class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer header with app branding
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'zmNinja',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ZoneMinder Mobile Client',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Navigation menu items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Montage'),
            onTap: () {
              Navigator.pop(context);
              context.go('/montage');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('Timeline'),
            onTap: () {
              Navigator.pop(context);
              context.go('/timeline');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () {
              Navigator.pop(context);
              context.go('/events');
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Logs'),
            onTap: () {
              Navigator.pop(context);
              context.go('/logs');
            },
          ),
          
          const Divider(),
          
          // App information
          const AboutListTile(
            icon: Icon(Icons.info),
            applicationName: 'zmNinja',
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2025 ZoneMinder Community',
            child: Text('About'),
          ),
        ],
      ),
    );
  }
}
