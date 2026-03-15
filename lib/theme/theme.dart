import 'package:flutter/material.dart';

import 'white_spaces.dart';

class MaterialTheme {

  const MaterialTheme(this.textTheme);
  final TextTheme textTheme;

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff8f4b39),
      surfaceTint: Color(0xff8f4b39),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdbd1),
      onPrimaryContainer: Color(0xff723524),
      secondary: Color(0xff77574e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdbd1),
      onSecondaryContainer: Color(0xff5d4038),
      tertiary: Color(0xff6c5d2e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfff7e1a6),
      onTertiaryContainer: Color(0xff534519),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff231917),
      onSurfaceVariant: Color(0xff53433f),
      outline: Color(0xff85736f),
      outlineVariant: Color(0xffd8c2bc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2b),
      inversePrimary: Color(0xffffb4a1),
      primaryFixed: Color(0xffffdbd1),
      onPrimaryFixed: Color(0xff3a0a01),
      primaryFixedDim: Color(0xffffb4a1),
      onPrimaryFixedVariant: Color(0xff723524),
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff2c150f),
      secondaryFixedDim: Color(0xffe7bdb3),
      onSecondaryFixedVariant: Color(0xff5d4038),
      tertiaryFixed: Color(0xfff7e1a6),
      onTertiaryFixed: Color(0xff231b00),
      tertiaryFixedDim: Color(0xffd9c58d),
      onTertiaryFixedVariant: Color(0xff534519),
      surfaceDim: Color(0xffe8d6d2),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ed),
      surfaceContainer: Color(0xfffceae6),
      surfaceContainerHigh: Color(0xfff7e4e0),
      surfaceContainerHighest: Color(0xfff1dfda),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff5d2515),
      surfaceTint: Color(0xff8f4b39),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa15946),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff4b2f28),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff87655c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff413509),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff7c6c3c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff180f0d),
      onSurfaceVariant: Color(0xff41332f),
      outline: Color(0xff5f4f4b),
      outlineVariant: Color(0xff7b6965),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2b),
      inversePrimary: Color(0xffffb4a1),
      primaryFixed: Color(0xffa15946),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff844231),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff87655c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff6d4d45),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff7c6c3c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff625426),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd4c3bf),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ed),
      surfaceContainer: Color(0xfff7e4e0),
      surfaceContainerHigh: Color(0xffebd9d5),
      surfaceContainerHighest: Color(0xffdfceca),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff501b0c),
      surfaceTint: Color(0xff8f4b39),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff753726),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3f261f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff60423a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff372b02),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff56481b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff372926),
      outlineVariant: Color(0xff554642),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2b),
      inversePrimary: Color(0xffffb4a1),
      primaryFixed: Color(0xff753726),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff592112),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff60423a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff472c25),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff56481b),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3e3106),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc6b5b1),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffffede9),
      surfaceContainer: Color(0xfff1dfda),
      surfaceContainerHigh: Color(0xffe2d1cc),
      surfaceContainerHighest: Color(0xffd4c3bf),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb4a1),
      surfaceTint: Color(0xffffb4a1),
      onPrimary: Color(0xff561f10),
      primaryContainer: Color(0xff723524),
      onPrimaryContainer: Color(0xffffdbd1),
      secondary: Color(0xffe7bdb3),
      onSecondary: Color(0xff442a23),
      secondaryContainer: Color(0xff5d4038),
      onSecondaryContainer: Color(0xffffdbd1),
      tertiary: Color(0xffd9c58d),
      onTertiary: Color(0xff3b2f05),
      tertiaryContainer: Color(0xff534519),
      onTertiaryContainer: Color(0xfff7e1a6),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff1a110f),
      onSurface: Color(0xfff1dfda),
      onSurfaceVariant: Color(0xffd8c2bc),
      outline: Color(0xffa08c88),
      outlineVariant: Color(0xff53433f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dfda),
      inversePrimary: Color(0xff8f4b39),
      primaryFixed: Color(0xffffdbd1),
      onPrimaryFixed: Color(0xff3a0a01),
      primaryFixedDim: Color(0xffffb4a1),
      onPrimaryFixedVariant: Color(0xff723524),
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff2c150f),
      secondaryFixedDim: Color(0xffe7bdb3),
      onSecondaryFixedVariant: Color(0xff5d4038),
      tertiaryFixed: Color(0xfff7e1a6),
      onTertiaryFixed: Color(0xff231b00),
      tertiaryFixedDim: Color(0xffd9c58d),
      onTertiaryFixedVariant: Color(0xff534519),
      surfaceDim: Color(0xff1a110f),
      surfaceBright: Color(0xff423734),
      surfaceContainerLowest: Color(0xff140c0a),
      surfaceContainerLow: Color(0xff231917),
      surfaceContainer: Color(0xff271d1b),
      surfaceContainerHigh: Color(0xff322825),
      surfaceContainerHighest: Color(0xff3d3230),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd2c7),
      surfaceTint: Color(0xffffb4a1),
      onPrimary: Color(0xff481507),
      primaryContainer: Color(0xffcb7c67),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffed3c8),
      onSecondary: Color(0xff381f19),
      secondaryContainer: Color(0xffae887f),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff0dba1),
      onTertiary: Color(0xff2f2400),
      tertiaryContainer: Color(0xffa18f5c),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1a110f),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffeed7d2),
      outline: Color(0xffc2ada8),
      outlineVariant: Color(0xffa08c87),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dfda),
      inversePrimary: Color(0xff743625),
      primaryFixed: Color(0xffffdbd1),
      onPrimaryFixed: Color(0xff290400),
      primaryFixedDim: Color(0xffffb4a1),
      onPrimaryFixedVariant: Color(0xff5d2515),
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff200b06),
      secondaryFixedDim: Color(0xffe7bdb3),
      onSecondaryFixedVariant: Color(0xff4b2f28),
      tertiaryFixed: Color(0xfff7e1a6),
      onTertiaryFixed: Color(0xff171000),
      tertiaryFixedDim: Color(0xffd9c58d),
      onTertiaryFixedVariant: Color(0xff413509),
      surfaceDim: Color(0xff1a110f),
      surfaceBright: Color(0xff4e423f),
      surfaceContainerLowest: Color(0xff0d0605),
      surfaceContainerLow: Color(0xff251b19),
      surfaceContainer: Color(0xff302623),
      surfaceContainerHigh: Color(0xff3b302d),
      surfaceContainerHighest: Color(0xff463b38),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffece7),
      surfaceTint: Color(0xffffb4a1),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffaf9a),
      onPrimaryContainer: Color(0xff1f0200),
      secondary: Color(0xffffece7),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffe3b9af),
      onSecondaryContainer: Color(0xff190603),
      tertiary: Color(0xffffefc7),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffd5c189),
      onTertiaryContainer: Color(0xff100b00),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff1a110f),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffece7),
      outlineVariant: Color(0xffd4beb9),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dfda),
      inversePrimary: Color(0xff743625),
      primaryFixed: Color(0xffffdbd1),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb4a1),
      onPrimaryFixedVariant: Color(0xff290400),
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffe7bdb3),
      onSecondaryFixedVariant: Color(0xff200b06),
      tertiaryFixed: Color(0xfff7e1a6),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffd9c58d),
      onTertiaryFixedVariant: Color(0xff171000),
      surfaceDim: Color(0xff1a110f),
      surfaceBright: Color(0xff5a4d4a),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff271d1b),
      surfaceContainer: Color(0xff392e2b),
      surfaceContainerHigh: Color(0xff443936),
      surfaceContainerHighest: Color(0xff504441),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
        checkColor: WidgetStateProperty.resolveWith((_) => Colors.black),
        side: WidgetStateBorderSide.resolveWith(
          (_) => const BorderSide(color: Colors.black54),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        alignLabelWithHint: true,
        isDense: false,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WhiteSpaces.buttonBorderRadius),
          borderSide: const BorderSide(width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WhiteSpaces.buttonBorderRadius),
          ),
        ),
      ),
    );
  }

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
