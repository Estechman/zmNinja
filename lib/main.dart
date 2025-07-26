import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'core/services/app_router.dart';
import 'core/services/notification_service.dart';
import 'shared/themes/app_theme.dart';

/// Main entry point for zmNinja Flutter application
/// Initializes Firebase, desktop window management, and Riverpod state management
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for push notifications (optional for static UI)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase not configured - continue without it for static UI testing
    print('Firebase initialization skipped: $e');
  }
  
  // Initialize desktop window management for Windows/macOS/Linux (skip for web)
  try {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.ensureInitialized();
      
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1200, 800),
        minimumSize: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  } catch (e) {
    // Platform detection not supported on web - continue without window management
    print('Window management skipped: $e');
  }
  
  // Initialize notification service
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: ZmNinjaApp(),
    ),
  );
}

/// Root application widget with Riverpod state management
/// Configures routing, theming, and global app settings
class ZmNinjaApp extends ConsumerWidget {
  const ZmNinjaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'zmNinja',
      debugShowCheckedModeBanner: false,
      
      // App theming for consistent UI across platforms
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Router configuration for navigation
      routerConfig: router,
      
      // Global navigator key for notification navigation
      navigatorKey: navigatorKey,
      
      // Localization support (placeholder for future implementation)
      // locale: const Locale('en', 'US'),
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

/// Global navigator key for navigation from notification handlers
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
