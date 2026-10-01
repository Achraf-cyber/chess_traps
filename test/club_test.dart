import 'package:chess_traps/data/club/club.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Clubs are typed into the Remote Config console by hand, so parsing has to
/// tolerate mistakes in one entry without losing the others.
void main() {
  group('Club.fromJson', () {
    test('reads a full entry', () {
      final club = Club.fromJson('echecs-lyon', {
        'name': ' Échiquier Lyonnais ',
        'logo': 'https://example.com/logo.png',
        'color': '#1E5AA8',
      })!;
      expect(club.code, 'ECHECS-LYON');
      expect(club.name, 'Échiquier Lyonnais');
      expect(club.logoUrl, 'https://example.com/logo.png');
      expect(club.color, const Color(0xFF1E5AA8));
    });

    test('only the name is required', () {
      final club = Club.fromJson('X', {'name': 'Club X'})!;
      expect(club.logoUrl, isNull);
      expect(club.color, isNull);
    });

    test('rejects entries without a usable name', () {
      expect(Club.fromJson('X', {'logo': 'https://a.b/c.png'}), isNull);
      expect(Club.fromJson('X', {'name': '  '}), isNull);
      expect(Club.fromJson('X', 'not a map'), isNull);
    });

    test('drops a bad color or a non-https logo instead of failing', () {
      final club = Club.fromJson('X', {
        'name': 'Club X',
        'logo': 'http://insecure.example/logo.png',
        'color': 'blue',
      })!;
      expect(club.logoUrl, isNull);
      expect(club.color, isNull);
    });

    test('survives a round trip through the device cache', () {
      final club = Club.fromJson('X', {
        'name': 'Club X',
        'logo': 'https://example.com/x.png',
        'color': '#00AA55',
      })!;
      final restored = Club.fromJson(club.code, club.toJson())!;
      expect(restored.name, club.name);
      expect(restored.logoUrl, club.logoUrl);
      expect(restored.color, club.color);
    });
  });

  test('codes ignore case and surrounding spaces', () {
    expect(Club.normalizeCode('  echecs-Lyon '), 'ECHECS-LYON');
  });

  test('initials use the first two words', () {
    expect(Club.fromJson('X', {'name': 'Cercle d\'Échecs de Paris'})!.initials,
        'CD');
    expect(Club.fromJson('X', {'name': 'Ouaga'})!.initials, 'O');
  });
}
