import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/core/services/app_link_service.dart';

/// Flutter-side animated splash shown as the app's first route.
///
/// The OS/native splash (a static logo on white) is unavoidable for the very
/// first moments of process start; this screen picks up seamlessly from it —
/// same logo, same white background — and then *animates*, so on every Android
/// version (not just 12+) the launch reads as alive rather than frozen. After
/// a short minimum display it routes on to onboarding or home.
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  // Matches the native splash background (windowSplashScreenBackground /
  // splash_master color = #FFFFFF) so the hand-off from native → Flutter
  // splash has no color flash.
  static const _bg = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    // Minimum on-screen time so the animation is actually seen, then route on.
    // Kept short (the heavy init already runs off the first frame) so the
    // splash never feels like the old freeze.
    Future<void>.delayed(const Duration(milliseconds: 1600), _goNext);
  }

  void _goNext() {
    if (!mounted) return;

    // A deep link that launched the app takes priority over the default
    // destination (but onboarding still comes first for brand-new users).
    final pendingTrap = AppLinkService.pendingInitialTrapIndex;
    if (pendingTrap != null && hasCompletedOnboarding) {
      AppLinkService.pendingInitialTrapIndex = null;
      TrapDetailRoute(index: pendingTrap).go(context);
      return;
    }

    if (hasCompletedOnboarding) {
      const HomeRoute().go(context);
    } else {
      const OnboardingRoute().go(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/app/splash_image.png', width: 160, height: 160)
                // Enter: fade + gentle overshoot scale, matching the static
                // native logo's position/size so it appears to "come alive".
                .animate()
                .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                // Then a continuous, subtle breathing pulse until we route away.
                .then()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1,
                  end: 1.06,
                  duration: 900.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 40),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
