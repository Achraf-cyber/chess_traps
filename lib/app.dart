import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:chess_traps/firebase_options.dart';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chess_traps/providers/app_theme_provider.dart';
import 'package:chess_traps/services/app_open_ad_manager.dart';
import 'package:chess_traps/services/remote_config_service.dart';
import 'package:chess_traps/services/notification_service.dart';
import 'package:chess_traps/services/consent_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:splash_master/splash_master.dart';


import 'l10n/app_localizations.dart';
import 'licenses.dart';
import 'router.dart';
import 'theme/theme.dart';
import 'theme/theme_utils.dart';

import 'services/app_link_service.dart';

Future<void> runMainApp(String envFile) async {
  var selectedEnvFile = envFile;
  if (kIsWeb) {
    usePathUrlStrategy();
  }


  debugPrint('app started');
  WidgetsFlutterBinding.ensureInitialized();

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

  await RemoteConfigService().initialize();

  // Determine which .env file to load based on remote config
  if (RemoteConfigService().showLiveAds) {
    selectedEnvFile = '.env.prod';
  } else {
    selectedEnvFile = '.env.dev';
  }

  // Defer first frame to keep the native splash screen until SplashMaster.resume() is called.
  SplashMaster.initialize();

  try {
    await dotenv.load(fileName: selectedEnvFile);
    debugPrint('loading dotenv: $selectedEnvFile');
  } catch (e) {
    debugPrint('Dotenv loading failed: $e');
  }

  await NotificationService().init();

  if (RemoteConfigService().adsEnabled && !kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      // Request privacy consent before initializing MobileAds
      await ConsentManager().requestConsentUpdate();

      // Initialize MobileAds and AppOpenAd
      MobileAds.instance.initialize().then((_) {
        debugPrint('initialize mobile ads');
        final appOpenAdManager = AppOpenAdManager()..loadAd();
        AppLifecycleReactor(
          appOpenAdManager: appOpenAdManager,
        ).listenToAppStateChanges();
      });
    } catch (e) {
      debugPrint('Consent/AdMob initialization failed: $e');
    }
  }

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
  WidgetsBinding.instance.addPostFrameCallback((_) => SplashMaster.resume());
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeProvider);
    const quicksand = 'Quicksand';
    final TextTheme textTheme = createTextTheme(context, quicksand, quicksand);

    final theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: kDebugMode && (kIsWeb || Platform.isWindows)
          ? DevicePreview.locale(context)
          : null,
      builder: kDebugMode && (kIsWeb || Platform.isWindows)
          ? DevicePreview.appBuilder
          : null,
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: themeMode,
    );
  }
}
