import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

extension I10nfromContext on BuildContext {
  AppLocalizations get phrase => AppLocalizations.of(this)!;
}

extension ColorsAlias on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
}

extension TextThemeAlias on BuildContext {
  TextTheme get textTheme {
    return Theme.of(this).textTheme;
  }
}

extension LightOrDark on BuildContext {
  bool get isLight {
    return Theme.of(this).brightness == Brightness.light;
  }
}
