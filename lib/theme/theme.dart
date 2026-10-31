import 'package:chess_traps/core/constants/app_colors.dart';
import 'package:chess_traps/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

/// Provides [light] and [dark] [ThemeData] for the app.
/// See [AppColors] for the design it is built on.
class MaterialTheme {
  const MaterialTheme(this.textTheme);
  final TextTheme textTheme;

  ThemeData light() => _build(_lightScheme());
  ThemeData dark() => _build(_darkScheme());

  // ── Schemes ────────────────────────────────────────────────────────

  static ColorScheme _darkScheme() => const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.sage,
    onPrimary: AppColors.sageDeep,
    primaryContainer: AppColors.sageTint,
    onPrimaryContainer: AppColors.sage,
    secondary: AppColors.chalkSoft,
    onSecondary: AppColors.night,
    secondaryContainer: AppColors.nightHigh,
    onSecondaryContainer: AppColors.chalk,
    tertiary: AppColors.ember,
    onTertiary: AppColors.night,
    tertiaryContainer: AppColors.emberTint,
    onTertiaryContainer: AppColors.ember,
    error: AppColors.wrongNight,
    onError: AppColors.night,
    errorContainer: AppColors.wrongNightTint,
    onErrorContainer: AppColors.wrongNight,
    surface: AppColors.night,
    onSurface: AppColors.chalk,
    onSurfaceVariant: AppColors.chalkSoft,
    outline: AppColors.nightRule,
    outlineVariant: AppColors.nightRuleSoft,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppColors.chalk,
    onInverseSurface: AppColors.night,
    inversePrimary: AppColors.forest,
    surfaceContainerLowest: AppColors.night,
    surfaceContainerLow: AppColors.nightRaised,
    surfaceContainer: AppColors.nightRaised,
    surfaceContainerHigh: AppColors.nightHigh,
    surfaceContainerHighest: AppColors.nightHighest,
    surfaceDim: AppColors.night,
    surfaceBright: AppColors.nightHigh,
  );

  static ColorScheme _lightScheme() => const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.forest,
    onPrimary: AppColors.paperRaised,
    primaryContainer: AppColors.forestTint,
    onPrimaryContainer: AppColors.forestDeep,
    secondary: AppColors.inkSoft,
    onSecondary: AppColors.paperRaised,
    secondaryContainer: AppColors.paperSunken,
    onSecondaryContainer: AppColors.ink,
    tertiary: AppColors.rust,
    onTertiary: AppColors.paperRaised,
    tertiaryContainer: AppColors.rustTint,
    onTertiaryContainer: AppColors.rustDeep,
    error: AppColors.wrong,
    onError: AppColors.paperRaised,
    errorContainer: AppColors.wrongTint,
    onErrorContainer: AppColors.wrongDeep,
    surface: AppColors.paper,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.inkSoft,
    outline: AppColors.rule,
    outlineVariant: AppColors.ruleSoft,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppColors.ink,
    onInverseSurface: AppColors.paper,
    inversePrimary: AppColors.sage,
    surfaceContainerLowest: AppColors.paperRaised,
    surfaceContainerLow: AppColors.paperRaised,
    surfaceContainer: AppColors.paperRaised,
    surfaceContainerHigh: AppColors.paperSunken,
    surfaceContainerHighest: AppColors.ruleSoft,
    surfaceDim: AppColors.paperSunken,
    surfaceBright: AppColors.paperRaised,
  );

  // ── Theme builder ──────────────────────────────────────────────────

  ThemeData _build(ColorScheme scheme) => ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    textTheme: textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,

    // ── App Bar ─────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: scheme.onSurface),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),

    // ── Navigation Bar ───────────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
          size: 22,
        );
      }),
    ),

    // ── Card ─────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: scheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      margin: EdgeInsets.zero,
    ),

    // ── Input ─────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // ── Chips ─────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainer,
      selectedColor: scheme.primaryContainer,
      side: BorderSide(color: scheme.outline.withValues(alpha: 0.4)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      labelStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    ),

    // ── Buttons ───────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        side: BorderSide(color: scheme.outline),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    // ── Misc ──────────────────────────────────────────────────────────
    dividerTheme: DividerThemeData(
      color: scheme.outline.withValues(alpha: 0.3),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(
        color: scheme.onInverseSurface,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      elevation: 0,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(scheme.onPrimary),
      side: WidgetStateBorderSide.resolveWith(
        (_) => BorderSide(color: scheme.outline),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return scheme.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primaryContainer;
        }
        return scheme.surfaceContainerHighest;
      }),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
    ),
  );
}
