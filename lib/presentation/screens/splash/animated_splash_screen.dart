import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/core/services/app_link_service.dart';
import 'package:chess_traps/utils.dart';

/// Flutter-side animated splash shown as the app's first route.
///
/// The OS/native splash (a static logo) is unavoidable for the very first
/// moments of process start; this screen picks up seamlessly from it — same
/// logo, matching background — and then *animates*, so on every Android
/// version (not just 12+) the launch reads as alive and premium rather than
/// frozen. After a short minimum display it routes on to onboarding or home.
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Minimum on-screen time so the entrance choreography is actually seen,
    // then route on. Kept short (heavy init already runs off the first frame)
    // so the splash never feels like the old freeze.
    Future<void>.delayed(const Duration(milliseconds: 2100), _goNext);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Match the native splash background so the hand-off has no colour flash.
    final bg = isDark ? const Color(0xFF0B0B0D) : const Color(0xFFFFFFFF);
    final logoAsset = isDark
        ? 'assets/app/splash_image_dark.png'
        : 'assets/app/splash_image.png';
    final accent = context.colors.primary;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo + a soft radial halo behind it for depth.
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Brand-tinted glow: fades and scales in behind the mark,
                  // giving the flat logo a sense of light and depth.
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accent.withValues(alpha: isDark ? 0.28 : 0.18),
                          accent.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 900.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1, 1),
                        duration: 1100.ms,
                        curve: Curves.easeOutCubic,
                      )
                      // Slow, barely-there pulse of the halo.
                      .then()
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(
                        begin: 1,
                        end: 1.08,
                        duration: 2200.ms,
                        curve: Curves.easeInOut,
                      ),
                  Image.asset(logoAsset, width: 148, height: 148)
                      // Smooth, weighty entrance — no toy-like bounce.
                      .animate()
                      .fadeIn(duration: 650.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.92, 0.92),
                        end: const Offset(1, 1),
                        duration: 750.ms,
                        curve: Curves.easeOutCubic,
                      )
                      // A very subtle, slow breath keeps it alive without
                      // reading as a nervous twitch.
                      .then()
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(
                        begin: 1,
                        end: 1.025,
                        duration: 2200.ms,
                        curve: Curves.easeInOut,
                      ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Elegant shimmering progress bar instead of a utilitarian spinner.
            _ShimmerBar(accent: accent, isDark: isDark)
                .animate()
                .fadeIn(delay: 650.ms, duration: 700.ms),
          ],
        ),
      ),
    );
  }
}

/// A slim, rounded track with a highlight that sweeps across it — a calmer,
/// more premium loading cue than a spinning ring.
class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({required this.accent, required this.isDark});

  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 4,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.22 : 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1500.ms,
          color: accent,
          size: 0.9,
        );
  }
}
