import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:chess_traps/firebase_options.dart';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chess_traps/core/providers/app_theme_provider.dart';
import 'package:chess_traps/core/providers/settings_provider.dart';
import 'package:chess_traps/core/services/app_open_ad_manager.dart';
import 'package:chess_traps/core/services/rewarded_ad_manager.dart';
import 'package:chess_traps/core/services/remote_config_service.dart';
import 'package:chess_traps/core/services/notification_service.dart';
import 'package:chess_traps/core/services/consent_manager.dart';
import 'package:chess_traps/core/services/audio_haptic_service.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:splash_master/splash_master.dart';

import 'package:chess_traps/l10n/app_localizations.dart';
import 'licenses.dart';
import 'router.dart';
import 'theme/theme.dart';
import 'theme/theme_utils.dart';

import 'package:chess_traps/core/services/app_link_service.dart';

Future<void> runMainApp() async {
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  debugPrint('app started');
  WidgetsFlutterBinding.ensureInitialized();

  // Read Onboarding State
  final prefs = await SharedPreferences.getInstance();
  hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize Native Deep Linking via app_links
    if (!kIsWeb) {
      await AppLinkService.init(router);
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  if (!kIsWeb) {
    try {
      // Pass all uncaught "fatal" errors from the framework to Crashlytics
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      debugPrint('Crashlytics setup failed: $e');
    }
  }

  debugPrint('widget binding');

  // Defer first frame to keep the native splash screen until SplashMaster.resume() is called.
  SplashMaster.initialize();

  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(<String>[
      'google_fonts',
    ], quicksandLicense);
    yield const LicenseEntryWithLineBreaks(<String>[
      'stockfish',
    ], stockfishLicense);
    yield const LicenseEntryWithLineBreaks(<String>[
      'lichess_data',
    ], lichessAttributions);
    yield const LicenseEntryWithLineBreaks(<String>[
      'sound_effects',
    ], soundAttributions);
  });

  if (kDebugMode && (kIsWeb || Platform.isWindows)) {
    // Animate.restartOnHotReload = true;
    runApp(
      DevicePreview(
        builder: (context) => const ProviderScope(child: MainApp()),
      ),
    );
  } else {
    runApp(const ProviderScope(child: MainApp()));
  }

  // Dismiss the native splash only after the first Flutter frame is drawn.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SplashMaster.resume();
    _initSecondaryServices();
  });
}

/// Everything the app needs *eventually* but that must never delay the first
/// frame. Awaiting any of this before runApp was what froze the splash
/// screen for up to ~30s (the notification-permission dialog blocks until
/// the user answers it).
Future<void> _initSecondaryServices() async {
  // Load the low-latency sound effects (move/capture/check). Non-blocking to
  // the first frame; degrades to haptics-only if it fails.
  unawaited(AudioHapticService().initialize());

  // Remote Config: generous timeout is fine now that the UI is visible;
  // defaults/cached values are used until (and if) the fetch completes.
  try {
    await RemoteConfigService().initialize().timeout(
      const Duration(seconds: 5),
    );
  } catch (e) {
    debugPrint('Remote Config init failed/timed out: $e');
  }

  if (RemoteConfigService().adsEnabled &&
      !kIsWeb &&
      (Platform.isAndroid || Platform.isIOS)) {
    try {
      // Request privacy consent before initializing MobileAds.
      ConsentManager()
          .requestConsentUpdate()
          .timeout(const Duration(seconds: 5))
          .then((_) {
            // Initialize MobileAds and AppOpenAd
            MobileAds.instance.initialize().then((_) {
              debugPrint('initialize mobile ads');
              final appOpenAdManager = AppOpenAdManager()..loadAd();
              RewardedAdManager().loadAd();
              AppLifecycleReactor(
                appOpenAdManager: appOpenAdManager,
              ).listenToAppStateChanges();
            });
          })
          .catchError((e) {
            debugPrint('Consent error/timeout: ');
          });
    } catch (e) {
      debugPrint('Consent/AdMob initialization failed: $e');
    }
  }

  // Notification setup last, and only after the first frames have settled:
  // it synchronously parses the timezone database, which would jank the
  // opening animation if run immediately.
  await Future<void>.delayed(const Duration(seconds: 1));
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }
}

/// Flat, non-elastic scrolling everywhere: no iOS bounce, no Android
/// stretch/glow overscroll indicator.
class _NoOverscrollBehavior extends MaterialScrollBehavior {
  const _NoOverscrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeProvider);
    const inter = 'Inter';
    final TextTheme textTheme = createTextTheme(context, inter, inter);

    final theme = MaterialTheme(textTheme);
    final settings = ref.watch(chessSettingsProvider);
    final locale = settings.localeCode != null
        ? Locale(settings.localeCode!)
        : null;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale:
          locale ??
          (kDebugMode && (kIsWeb || Platform.isWindows)
              ? DevicePreview.locale(context)
              : null),
      builder: kDebugMode && (kIsWeb || Platform.isWindows)
          ? DevicePreview.appBuilder
          : null,
      scrollBehavior: const _NoOverscrollBehavior(),
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: themeMode,
    );
  }
}
