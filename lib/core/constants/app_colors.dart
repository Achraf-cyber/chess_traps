import 'package:flutter/material.dart';

/// Design token palette for Chess Traps.
/// Dark-first: deep slate backgrounds + chess-gold accent.
abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────
  static const Color bg = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color card = Color(0xFF1C2333);
  static const Color cardElevated = Color(0xFF21273A);

  // ── Accent (chess gold) ───────────────────────────────────────────
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldDim = Color(0xFFA08830);
  static const Color goldSurface = Color(0xFF2A2215);

  // ── Semantic ─────────────────────────────────────────────────────
  static const Color green = Color(0xFF3FB950);
  static const Color greenSurface = Color(0xFF0D2B1A);
  static const Color red = Color(0xFFF85149);
  static const Color redSurface = Color(0xFF2D1217);
  static const Color blue = Color(0xFF58A6FF);

  // ── Text ─────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF484F58);

  // ── Borders ──────────────────────────────────────────────────────
  static const Color border = Color(0xFF30363D);
  static const Color borderSubtle = Color(0xFF21262D);

  // ── Light theme ───────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFF0F0F0);
  static const Color lightCard = Color(0xFFE5E8EC);
  static const Color lightGold = Color(0xFF8B6914);
  static const Color lightTextPrimary = Color(0xFF1F2328);
  static const Color lightTextSecondary = Color(0xFF57606A);
  static const Color lightBorder = Color(0xFFD0D7DE);
}
