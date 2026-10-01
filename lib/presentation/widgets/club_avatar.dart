import 'package:chess_traps/data/club/club.dart';
import 'package:flutter/material.dart';

/// Round club logo, falling back to the club's initials on its color when
/// there is no logo or it can't be loaded (offline, dead link).
class ClubAvatar extends StatelessWidget {
  const ClubAvatar({super.key, required this.club, this.size = 32});

  final Club club;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = club.color ?? Theme.of(context).colorScheme.primary;
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: color,
      child: Text(
        club.initials,
        style: TextStyle(
          color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.4,
        ),
      ),
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: club.logoUrl == null
            ? fallback
            : Image.network(
                club.logoUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : fallback,
              ),
      ),
    );
  }
}
