import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme createTextTheme(
  BuildContext context,
  String bodyFontString,
  String displayFontString,
) {
  final TextTheme base = Theme.of(context).textTheme;

  // Style by style rather than GoogleFonts.getTextTheme: since 9.0 that returns
  // material_ui's TextTheme, which isn't the type ThemeData takes.
  TextStyle body(TextStyle? style) =>
      GoogleFonts.getFont(bodyFontString, textStyle: style);
  TextStyle display(TextStyle? style) =>
      GoogleFonts.getFont(displayFontString, textStyle: style);

  return base.copyWith(
    displayLarge: display(base.displayLarge),
    displayMedium: display(base.displayMedium),
    displaySmall: display(base.displaySmall),
    headlineLarge: display(base.headlineLarge),
    headlineMedium: display(base.headlineMedium),
    headlineSmall: display(base.headlineSmall),
    titleLarge: display(base.titleLarge),
    titleMedium: display(base.titleMedium),
    titleSmall: display(base.titleSmall),
    bodyLarge: body(base.bodyLarge),
    bodyMedium: body(base.bodyMedium),
    bodySmall: body(base.bodySmall),
    labelLarge: body(base.labelLarge),
    labelMedium: body(base.labelMedium),
    labelSmall: body(base.labelSmall),
  );
}
