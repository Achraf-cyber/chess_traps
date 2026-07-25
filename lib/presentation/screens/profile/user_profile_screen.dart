import 'package:chess_traps/core/constants/app_sizes.dart';
import 'package:chess_traps/presentation/state/favorites/user_favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chess_traps/core/providers/app_theme_provider.dart';
import 'package:chess_traps/router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils.dart';
import 'package:chess_traps/core/services/notification_service.dart';
import 'package:chess_traps/core/providers/settings_provider.dart';
import 'package:chess_traps/presentation/state/streak/streak_provider.dart';
import 'package:chess_traps/presentation/state/play/play_history_provider.dart';
import 'package:chess_traps/presentation/state/traps/learned_traps_provider.dart';
import 'package:chess_traps/generated/chess/base_chess_traps.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeProvider);
    final themeNotifier = ref.read(appThemeProvider.notifier);
    final favoritesCount = ref.watch(userFavoritesProvider).length;
    final streakCount = ref.watch(streakProvider).count;
    final history = ref.watch(playHistoryProvider);
    final learnedCount = ref.watch(learnedTrapsProvider).length;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────
          _SettingsHeader(scheme: scheme),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics dashboard
                  _SectionTitle(title: context.phrase.statistics),
                  const SizedBox(height: 12),
                  _StatsDashboard(
                    wins: history.wins,
                    draws: history.draws,
                    losses: history.losses,
                    streak: streakCount,
                    learned: learnedCount,
                    totalTraps: chessTraps.length,
                  ),
                  const SizedBox(height: 28),

                  // Appearance
                  _SectionTitle(title: context.phrase.appearance),
                  const SizedBox(height: 12),
                  _ThemeSelector(
                    currentMode: themeMode,
                    notifier: themeNotifier,
                  ),
                  const SizedBox(height: 16),
                  const _BoardThemeSelector(),
                  const SizedBox(height: 28),

                  // Sound & haptics
                  _SectionTitle(title: context.phrase.soundAndHaptics),
                  const SizedBox(height: 12),
                  const _SoundHapticSettings(),
                  const SizedBox(height: 28),

                  // Language
                  _SectionTitle(title: context.phrase.localeName),
                  const SizedBox(height: 12),
                  const _LanguageSelector(),
                  const SizedBox(height: 28),

                  // Notifications
                  _SectionTitle(title: context.phrase.notifications),
                  const SizedBox(height: 12),
                  const _NotificationSettings(),
                  const SizedBox(height: 28),

                  // Data
                  _SectionTitle(title: context.phrase.dataManagement),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.favorite_rounded,
                    iconColor: scheme.error,
                    title: context.phrase.yourFavorites,
                    subtitle: context.phrase.favoritesCount(favoritesCount),
                    onTap: () => const FavoritesRoute().go(context),
                  ),
                  _SettingsTile(
                    icon: Icons.delete_sweep_rounded,
                    iconColor: scheme.error,
                    title: context.phrase.clearFavoritesTitle,
                    subtitle: context.phrase.clearFavoritesHint,
                    onTap: () => _confirmClearFavorites(context, ref),
                  ),
                  const SizedBox(height: 28),

                  // About
                  _SectionTitle(title: context.phrase.about),
                  const SizedBox(height: 12),
                  const _AppVersionTile(),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: context.phrase.privacyPolicy,
                    onTap: () => launchUrl(
                      Uri.parse(
                        'https://achraf-cyber.github.io/privacy/privacy-policy.html',
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.article_outlined,
                    title: context.phrase.openSourceLicense,
                    subtitle: context.phrase.usedPackages,
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: context.phrase.appName,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Copyright
                  Center(
                    child: Text(
                      context.phrase.copyright,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearFavorites(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.phrase.clearFavoritesTitle),
        content: Text(context.phrase.clearFavoritesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.phrase.clearFavoritesCancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(userFavoritesProvider.notifier).clear();
              Navigator.pop(ctx);
            },
            child: Text(
              context.phrase.clearFavoritesAction,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header sliver (clean, no gradient)
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: scheme.surfaceContainerLow,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 28,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.phrase.profileTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section title
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.0,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings tile
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.25),
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (iconColor ?? scheme.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: iconColor ?? scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme selector
// ─────────────────────────────────────────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.currentMode, required this.notifier});
  final ThemeMode currentMode;
  final AppThemeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          _ThemeOption(
            label: context.phrase.system,
            icon: Icons.brightness_auto_rounded,
            selected: currentMode == ThemeMode.system,
            onTap: () => notifier.setThemeMode(ThemeMode.system),
          ),
          _ThemeOption(
            label: context.phrase.light,
            icon: Icons.light_mode_rounded,
            selected: currentMode == ThemeMode.light,
            onTap: () => notifier.setThemeMode(ThemeMode.light),
          ),
          _ThemeOption(
            label: context.phrase.dark,
            icon: Icons.dark_mode_rounded,
            selected: currentMode == ThemeMode.dark,
            onTap: () => notifier.setThemeMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Language selector
// ─────────────────────────────────────────────────────────────────────────────

class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chessSettingsProvider);
    final notifier = ref.read(chessSettingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    final languages = [
      {'code': null, 'label': context.phrase.system, 'flag': '🌐'},
      {'code': 'en', 'label': 'English', 'flag': '🇺🇸'},
      {'code': 'fr', 'label': 'Français', 'flag': '🇫🇷'},
      {'code': 'es', 'label': 'Español', 'flag': '🇪🇸'},
      {'code': 'ar', 'label': 'العربية', 'flag': '🇲🇦'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: List.generate(languages.length, (i) {
          final lang = languages[i];
          final isSelected = settings.localeCode == lang['code'];
          final isFirst = i == 0;
          final isLast = i == languages.length - 1;

          return InkWell(
            onTap: () => notifier.updateLocale(lang['code']),
            borderRadius: BorderRadius.vertical(
              top: isFirst ? const Radius.circular(AppSizes.radiusL) : Radius.zero,
              bottom: isLast ? const Radius.circular(AppSizes.radiusL) : Radius.zero,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: scheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Text(lang['flag'] as String, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 14),
                  Text(
                    lang['label'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(Icons.check_rounded, size: 18, color: scheme.primary),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification settings
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationSettings extends StatefulWidget {
  const _NotificationSettings();

  @override
  State<_NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<_NotificationSettings> {
  bool _enabled = true;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enabled = prefs.getBool('notification_enabled') ?? true;
      _time = TimeOfDay(
        hour: prefs.getInt('notification_time_hour') ?? 9,
        minute: prefs.getInt('notification_time_minute') ?? 0,
      );
      _loading = false;
    });
  }

  Future<void> _update(bool enabled, TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', enabled);
    await prefs.setInt('notification_time_hour', time.hour);
    await prefs.setInt('notification_time_minute', time.minute);
    if (mounted) setState(() { _enabled = enabled; _time = time; });
    if (enabled) {
      await NotificationService().scheduleDailyNotification(time);
    } else {
      await NotificationService().cancelNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              context.phrase.daily_trap_reminder,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              context.phrase.daily_trap_reminder_subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            value: _enabled,
            onChanged: (val) => _update(val, _time),
            activeThumbColor: scheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(AppSizes.radiusL),
                bottom: _enabled ? Radius.zero : const Radius.circular(AppSizes.radiusL),
              ),
            ),
          ),
          if (_enabled)
            ListTile(
              title: Text(
                context.phrase.reminder_time,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                _time.format(context),
                style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.access_time_rounded, color: scheme.primary),
              onTap: () async {
                final newTime = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (newTime != null) _update(true, newTime);
              },
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppSizes.radiusL),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Statistics dashboard
// ─────────────────────────────────────────────────────────────────────────────

class _StatsDashboard extends StatelessWidget {
  const _StatsDashboard({
    required this.wins,
    required this.draws,
    required this.losses,
    required this.streak,
    required this.learned,
    required this.totalTraps,
  });

  final int wins;
  final int draws;
  final int losses;
  final int streak;
  final int learned;
  final int totalTraps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events_rounded,
                iconColor: Colors.green,
                value: '$wins',
                label: context.phrase.wins,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.handshake_rounded,
                iconColor: Colors.orange,
                value: '$draws',
                label: context.phrase.draws,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.psychology_rounded,
                iconColor: Colors.redAccent,
                value: '$losses',
                label: context.phrase.losses,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: scheme.tertiary,
                value: '$streak',
                label: context.phrase.currentStreak,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.school_rounded,
                iconColor: scheme.primary,
                value: '$learned',
                label: context.phrase.trapsLearned,
                sublabel: context.phrase.learnedProgress(learned, totalTraps),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.sublabel,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 1),
            Text(
              sublabel!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Board theme selector
// ─────────────────────────────────────────────────────────────────────────────

class _BoardThemeSelector extends ConsumerWidget {
  const _BoardThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chessSettingsProvider);
    final notifier = ref.read(chessSettingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.grid_view_rounded, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              context.phrase.boardTheme,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          DropdownButton<AppBoardTheme>(
            value: settings.boardTheme,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            items: AppBoardTheme.values.map((theme) {
              return DropdownMenuItem(
                value: theme,
                child: Text(theme.label),
              );
            }).toList(),
            onChanged: (theme) {
              if (theme != null) notifier.updateBoardTheme(theme);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sound & haptics settings
// ─────────────────────────────────────────────────────────────────────────────

class _SoundHapticSettings extends ConsumerWidget {
  const _SoundHapticSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chessSettingsProvider);
    final notifier = ref.read(chessSettingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(Icons.volume_up_rounded, color: scheme.onSurfaceVariant),
            title: Text(
              context.phrase.soundEffects,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            value: settings.soundEnabled,
            onChanged: notifier.updateSoundEnabled,
            activeThumbColor: scheme.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusL),
              ),
            ),
          ),
          Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
          SwitchListTile(
            secondary: Icon(Icons.vibration_rounded, color: scheme.onSurfaceVariant),
            title: Text(
              context.phrase.hapticFeedback,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            value: settings.hapticsEnabled,
            onChanged: notifier.updateHapticsEnabled,
            activeThumbColor: scheme.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppSizes.radiusL),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App version tile (reads the real version at runtime)
// ─────────────────────────────────────────────────────────────────────────────

class _AppVersionTile extends StatefulWidget {
  const _AppVersionTile();

  @override
  State<_AppVersionTile> createState() => _AppVersionTileState();
}

class _AppVersionTileState extends State<_AppVersionTile> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = '${info.version} (${info.buildNumber})');
      }
    } catch (_) {
      // Leave version null; the tile simply shows no subtitle.
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: Icons.info_outline_rounded,
      title: context.phrase.appVersion,
      subtitle: _version,
    );
  }
}
