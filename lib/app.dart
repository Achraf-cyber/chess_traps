import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chess_traps/providers/app_theme_provider.dart';
import 'package:chess_traps/services/app_open_ad_manager.dart';
import 'package:chess_traps/services/notification_service.dart';
import 'package:chess_traps/services/consent_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:splash_master/splash_master.dart';

import 'generated/assets.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'theme/theme.dart';
import 'theme/theme_utils.dart';

Future<void> runMainApp(String envFile) async {
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  debugPrint('app started');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('widget binding');

  // Defer first frame to keep the native splash screen until SplashMaster.resume() is called.
  SplashMaster.initialize();

  await dotenv.load(fileName: envFile);
  debugPrint('loading dotenv');

  await NotificationService().init();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    // Request privacy consent before initializing MobileAds
    await ConsentManager().requestConsentUpdate();
    
    // Initialize MobileAds and AppOpenAd
    MobileAds.instance.initialize().then(
      (_) {
        debugPrint('initialize mobile ads');
        final appOpenAdManager = AppOpenAdManager()..loadAd();
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager)
            .listenToAppStateChanges();
      },
    );
  }

  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString(
      AppAssets.googleFontsQuicksandOflTxt,
    );
    yield LicenseEntryWithLineBreaks(<String>['google_fonts'], license);
  });
  LicenseRegistry.addLicense(() async* {
    const license = 'Creative Commons BY, https://rive.app/@Ayushb58/';
    yield const LicenseEntryWithLineBreaks(<String>['Ayushb58'], license);
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
