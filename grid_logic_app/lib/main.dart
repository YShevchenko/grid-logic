// Grid Logic - Einstein's Riddle Logic Game
// Main entry point with Firebase, Ads, and IAP initialization

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/theme/app_theme.dart';
import 'providers/game_state.dart';
import 'services/ad_service.dart';
import 'services/iap_service.dart';
import 'screens/menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set portrait orientation only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase (only if firebase_options.dart exists)
  try {
    await Firebase.initializeApp();
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }

  // Initialize services
  await AdService.instance.initialize();
  await IAPService.instance.initialize();

  // Sync IAP state with Ad Service
  AdService.instance.setAdsRemoved(IAPService.instance.adsRemoved);

  runApp(const ProviderScope(child: GridLogicApp()));
}

class GridLogicApp extends ConsumerWidget {
  const GridLogicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Grid Logic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
      home: const MenuScreen(),
    );
  }
}
