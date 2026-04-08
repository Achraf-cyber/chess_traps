import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chess_traps/providers/app_theme_provider.dart';
import 'package:chess_traps/services/billing_service.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

import 'generated/assets.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'theme/theme.dart';
import 'theme/theme_utils.dart';

void main() async {
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await MobileAds.instance.initialize();
    await BillingService.init();
  }

  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString(AppAssets.googleFontsQuicksandOflTxt);
    yield LicenseEntryWithLineBreaks(<String>['google_fonts'], license);
  });
  LicenseRegistry.addLicense(() async* {
    const license = 'Creative Commons BY, https://rive.app/@Ayushb58/';
    yield const LicenseEntryWithLineBreaks(<String>['Ayushb58'], license);
  });

  if (kDebugMode && (kIsWeb || Platform.isWindows)) {
    // Animate.restartOnHotReload = true;
    runApp(DevicePreview(builder: (context) => const ProviderScope(child: MainApp())));
  } else {
    runApp(const ProviderScope(child: MainApp()));
  }
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
      locale: kDebugMode && (kIsWeb || Platform.isWindows) ? DevicePreview.locale(context) : null,
      builder: kDebugMode && (kIsWeb || Platform.isWindows) ? DevicePreview.appBuilder : null,
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: themeMode,
    );
  }
}
