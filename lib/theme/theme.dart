import 'package:chess_traps/core/constants/app_colors.dart';
import 'package:chess_traps/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

/// Provides [light] and [dark] [ThemeData] for the app.
/// Built on a dark-slate + chess-gold design system.
class MaterialTheme {
  const MaterialTheme(this.textTheme);
  final TextTheme textTheme;

  ThemeData light() => _build(_lightScheme());
  ThemeData dark() => _build(_darkScheme());

  // ── Schemes ────────────────────────────────────────────────────────

  static ColorScheme _darkScheme() => const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.gold,
    onPrimary: Color(0xFF0D0A00),
    primaryContainer: AppColors.goldSurface,
    onPrimaryContainer: AppColors.gold,
    secondary: AppColors.textSecondary,
    onSecondary: AppColors.bg,
    secondaryContainer: AppColors.card,
    onSecondaryContainer: AppColors.textPrimary,
    tertiary: AppColors.blue,
    onTertiary: AppColors.bg,
    tertiaryContainer: Color(0xFF0D1F3C),
    onTertiaryContainer: AppColors.blue,
    error: AppColors.red,
    onError: Color(0xFF210000),
    errorContainer: AppColors.redSurface,
    onErrorContainer: AppColors.red,
    surface: AppColors.bg,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.borderSubtle,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppColors.textPrimary,
    inversePrimary: AppColors.lightGold,
    surfaceContainerLowest: Color(0xFF090D12),
    surfaceContainerLow: AppColors.surface,
    surfaceContainer: AppColors.card,
    surfaceContainerHigh: AppColors.cardElevated,
    surfaceContainerHighest: Color(0xFF2C3345),
    surfaceDim: AppColors.bg,
    surfaceBright: AppColors.card,
  );

  static ColorScheme _lightScheme() => const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lightGold,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF5E9C8),
    onPrimaryContainer: Color(0xFF5C4308),
    secondary: AppColors.lightTextSecondary,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8E8EE),
    onSecondaryContainer: AppColors.lightTextPrimary,
    tertiary: Color(0xFF0969DA),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFDFEEFF),
    onTertiaryContainer: Color(0xFF003568),
    error: Color(0xFFCF222E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDDD8),
    onErrorContainer: Color(0xFF7D0A00),
    surface: AppColors.lightBg,
    onSurface: AppColors.lightTextPrimary,
    onSurfaceVariant: AppColors.lightTextSecondary,
    outline: AppColors.lightBorder,
    outlineVariant: Color(0xFFE0E6ED),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppColors.lightTextPrimary,
    inversePrimary: AppColors.gold,
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF6F8FA),
    surfaceContainer: AppColors.lightSurface,
    surfaceContainerHigh: AppColors.lightCard,
    surfaceContainerHighest: Color(0xFFDDE1E6),
    surfaceDim: Color(0xFFE8ECEF),
    surfaceBright: Color(0xFFFFFFFF),
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
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
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
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.4)),
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
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        side: BorderSide(color: scheme.outline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
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
        color: scheme.surface,
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
