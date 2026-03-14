import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

import 'generated/assets.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'theme/theme.dart';
import 'theme/theme_utils.dart';

void main() {
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString(AppAssets.googleFontsQuicksandOflTxt);
    yield LicenseEntryWithLineBreaks(<String>['google_fonts'], license);
  });
  LicenseRegistry.addLicense(() async* {
    final String license = "Creative Commons BY, https://rive.app/@Ayushb58/";
    yield LicenseEntryWithLineBreaks(<String>['Ayushb58'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode && (kIsWeb || Platform.isWindows)) {
    // Animate.restartOnHotReload = true;
    runApp(
      DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => ProviderScope(child: const MainApp()),
      ),
    );
  } else {
    runApp(ProviderScope(child: const MainApp()));
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    final quicksand = "Quicksand";
    TextTheme textTheme = createTextTheme(context, quicksand, quicksand);

    MaterialTheme theme = MaterialTheme(textTheme);
    if (kDebugMode && kIsWeb) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chess traps',
        themeMode: ThemeMode.light,
        theme: theme.light(),
        darkTheme: theme.dark(),
        home: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          theme: theme.light(),
          darkTheme: theme.dark(),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chess traps',
      themeMode: ThemeMode.light,
      theme: theme.light(),
      darkTheme: theme.dark(),
      home: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: theme.light(),
        darkTheme: theme.dark(),
        themeMode: ThemeMode.light,
      ),
    );
  }
}
