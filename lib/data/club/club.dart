import 'package:flutter/material.dart';

/// A chess club whose members joined Trapsters with the club's code.
///
/// Clubs live in the `clubs` Remote Config parameter, a JSON object keyed by
/// code, so adding or revoking one is a console edit rather than a release:
///
/// ```json
/// {
///   "ECHECS-LYON": {
///     "name": "Échiquier Lyonnais",
///     "logo": "https://example.com/logo.png",
///     "color": "#1E5AA8"
///   }
/// }
/// ```
///
/// Only `name` is required. `logo` falls back to the club's initials and
/// `color` to the app's primary color.
class Club {
  const Club({
    required this.code,
    required this.name,
    this.logoUrl,
    this.color,
  });

  final String code;
  final String name;
  final String? logoUrl;
  final Color? color;

  /// Codes are typed by hand from a WhatsApp message or a poster, so case and
  /// stray whitespace must not matter.
  static String normalizeCode(String code) => code.trim().toUpperCase();

  /// Parses one entry of the Remote Config map. Returns null when the entry
  /// has no usable name, so a typo in the console hides one club instead of
  /// breaking the lookup for all of them.
  static Club? fromJson(String code, Object? json) {
    if (json is! Map) return null;
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) return null;
    final logo = json['logo'];
    final color = json['color'];
    return Club(
      code: normalizeCode(code),
      name: name.trim(),
      logoUrl: logo is String && logo.startsWith('https://') ? logo : null,
      color: color is String ? _parseHex(color) : null,
    );
  }

  Map<String, Object?> toJson() => {
    'name': name,
    if (logoUrl != null) 'logo': logoUrl,
    if (color != null)
      'color':
          '#${(color!.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
  };

  /// Up to two letters for the placeholder avatar shown when there is no logo
  /// or it fails to load.
  String get initials {
    final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w.characters.first.toUpperCase()).join();
  }

  static Color? _parseHex(String hex) {
    final digits = hex.replaceFirst('#', '');
    if (digits.length != 6) return null;
    final value = int.tryParse(digits, radix: 16);
    return value == null ? null : Color(0xFF000000 | value);
  }
}
