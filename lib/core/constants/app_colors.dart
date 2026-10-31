import 'package:flutter/material.dart';

/// Design token palette for Trapster: the look of a printed chess book.
/// Warm paper and ink, with the green of a tournament board as the one accent.
/// Use the [ColorScheme] in widgets; these only feed `theme.dart`.
abstract final class AppColors {
  // ── Light: paper ────────────────────────────────────────────────────
  static const Color paper = Color(0xFFF7F3EC);
  static const Color paperRaised = Color(0xFFFFFDF8);
  static const Color paperSunken = Color(0xFFEFE9DE);
  static const Color ink = Color(0xFF1E1B16);
  static const Color inkSoft = Color(0xFF6B6358);
  static const Color rule = Color(0xFFD9D0C1);
  static const Color ruleSoft = Color(0xFFE6DFD2);
  static const Color forest = Color(0xFF2F5D46);
  static const Color forestTint = Color(0xFFDCE7DF);
  static const Color forestDeep = Color(0xFF17372A);
  static const Color rust = Color(0xFFA9481F);
  static const Color rustTint = Color(0xFFF3DFD3);
  static const Color rustDeep = Color(0xFF5E2610);
  static const Color wrong = Color(0xFFB3261E);
  static const Color wrongTint = Color(0xFFF7DEDB);
  static const Color wrongDeep = Color(0xFF5F120E);

  // ── Dark: the same book at night ────────────────────────────────────
  static const Color night = Color(0xFF171513);
  static const Color nightRaised = Color(0xFF211E1B);
  static const Color nightHigh = Color(0xFF2B2723);
  static const Color nightHighest = Color(0xFF36312C);
  static const Color chalk = Color(0xFFEFE9DF);
  static const Color chalkSoft = Color(0xFFA99F91);
  static const Color nightRule = Color(0xFF423C35);
  static const Color nightRuleSoft = Color(0xFF332E29);
  static const Color sage = Color(0xFF8FBF9F);
  static const Color sageTint = Color(0xFF2B3A31);
  static const Color sageDeep = Color(0xFF10261A);
  static const Color ember = Color(0xFFE08A5B);
  static const Color emberTint = Color(0xFF43291B);
  static const Color wrongNight = Color(0xFFEF8A80);
  static const Color wrongNightTint = Color(0xFF45201C);
}
