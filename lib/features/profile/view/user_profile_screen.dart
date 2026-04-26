import 'package:chess_traps/providers/user_favorites_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chess_traps/providers/app_theme_provider.dart';
import 'package:chess_traps/router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils.dart';
import '../../../services/notification_service.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeProvider);
    final AppThemeNotifier themeNotifier = ref.read(appThemeProvider.notifier);
    final favoritesCount = ref.watch(userFavoritesProvider).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const _ProfileHeaderSliver(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileSectionTitle(title: context.phrase.appearance),
                  const SizedBox(height: 16),
                  _ProfileThemeSelector(
                    currentMode: themeMode,
                    notifier: themeNotifier,
                  ),
                  const SizedBox(height: 32),
                  const _ProfileSectionTitle(title: "Notifications"),
                  const SizedBox(height: 16),
                  const _ProfileNotificationSettings(),
                  const SizedBox(height: 32),
                  _ProfileSectionTitle(title: context.phrase.dataManagement),
                  const SizedBox(height: 16),
                  _ProfileSettingsTile(
                    icon: Icons.favorite_rounded,
                    title: context.phrase.yourFavorites,
                    subtitle: context.phrase.favoritesCount(favoritesCount),
                    onTap: () => const FavoritesRoute().go(context),
                  ),
                  _ProfileSettingsTile(
                    icon: Icons.delete_sweep_rounded,
                    title: context.phrase.clearFavoritesTitle,
                    subtitle: context.phrase.clearFavoritesHint,
                    iconColor: Colors.red,
                    onTap: () => _confirmClearFavorites(context, ref),
                  ),
                  const SizedBox(height: 32),
                  _ProfileSectionTitle(title: context.phrase.about),
                  const SizedBox(height: 16),
                  _ProfileSettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: context.phrase.appVersion,
                    subtitle: "1.2.0 (Premium UI)",
                  ),
                  _ProfileSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: context.phrase.privacyPolicy,
                    onTap: () => launchUrl(
                      Uri.parse(
                        "https://achraf-cyber.github.io/privacy/privacy-policy.html",
                      ),
                    ),
                  ),
                  _ProfileSettingsTile(
                    icon: Icons.gavel_rounded,
                    title: context.phrase.termsOfUse,
                    onTap: () {
                      // Placeholder for Terms of Use if needed, or link to same page if applicable
                    },
                  ),
                  _ProfileSettingsTile(
                    icon: Icons.article_outlined,
                    title: context.phrase.openSourceLicense,
                    subtitle: context.phrase.usedPackages,
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: context.phrase.appName,
                        applicationVersion: "1.2.0",
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      context.phrase.copyright,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.outline.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
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
      builder: (context) => AlertDialog(
        title: Text(context.phrase.clearFavoritesTitle),
        content: Text(context.phrase.clearFavoritesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.phrase.clearFavoritesCancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(userFavoritesProvider.notifier).clear();
              Navigator.pop(context);
            },
            child: Text(
              context.phrase.clearFavoritesAction,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderSliver extends StatelessWidget {
  const _ProfileHeaderSliver();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colors.primaryContainer,
                    context.colors.surface,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 24,
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: context.colors.primary,
                        child: const Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.phrase.profileTitle,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: context.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.colors.primary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ProfileThemeSelector extends StatelessWidget {
  const _ProfileThemeSelector({
    required this.currentMode,
    required this.notifier,
  });

  final ThemeMode currentMode;
  final AppThemeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          _ProfileThemeOption(
            label: context.phrase.system,
            icon: Icons.brightness_auto,
            isSelected: currentMode == ThemeMode.system,
            onTap: () => notifier.setThemeMode(ThemeMode.system),
          ),
          _ProfileThemeOption(
            label: context.phrase.light,
            icon: Icons.light_mode_rounded,
            isSelected: currentMode == ThemeMode.light,
            onTap: () => notifier.setThemeMode(ThemeMode.light),
          ),
          _ProfileThemeOption(
            label: context.phrase.dark,
            icon: Icons.dark_mode_rounded,
            isSelected: currentMode == ThemeMode.dark,
            onTap: () => notifier.setThemeMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ProfileThemeOption extends StatelessWidget {
  const _ProfileThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? context.colors.onPrimary
                    : context.colors.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? context.colors.onPrimary
                      : context.colors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSettingsTile extends StatelessWidget {
  const _ProfileSettingsTile({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? context.colors.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colors.outlineVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileNotificationSettings extends StatefulWidget {
  const _ProfileNotificationSettings();

  @override
  State<_ProfileNotificationSettings> createState() =>
      _ProfileNotificationSettingsState();
}

class _ProfileNotificationSettingsState
    extends State<_ProfileNotificationSettings> {
  bool _enabled = true;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _loading = true;
  bool _canScheduleExactAlarms = true;
  bool _ignoringBatteryOptimizations = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final canScheduleExactAlarms = await NotificationService()
        .canScheduleExactAlarms();
    final ignoringBatteryOptimizations = await NotificationService()
        .isIgnoringBatteryOptimizations();

    setState(() {
      _enabled = prefs.getBool('notification_enabled') ?? true;
      final hour = prefs.getInt('notification_time_hour') ?? 9;
      final minute = prefs.getInt('notification_time_minute') ?? 0;
      _time = TimeOfDay(hour: hour, minute: minute);
      _canScheduleExactAlarms = canScheduleExactAlarms;
      _ignoringBatteryOptimizations = ignoringBatteryOptimizations;
      _loading = false;
    });
  }

  Future<void> _updateSettings(bool enabled, TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', enabled);
    await prefs.setInt('notification_time_hour', time.hour);
    await prefs.setInt('notification_time_minute', time.minute);

    setState(() {
      _enabled = enabled;
      _time = time;
    });

    if (enabled) {
      await NotificationService().scheduleDailyNotification(time);
    } else {
      await NotificationService().cancelNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // ignore: deprecated_member_use
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              "Daily Trap Reminder",
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Get notified to check the trap of the day",
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            value: _enabled,
            onChanged: (val) {
              _updateSettings(val, _time);
            },
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          if (_enabled)
            ListTile(
              title: Text(
                "Reminder Time",
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _time.format(context),
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.access_time_rounded),
              onTap: () async {
                final newTime = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (newTime != null) {
                  _updateSettings(true, newTime);
                }
              },
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
            ),
          if (_enabled && Platform.isAndroid && (!_canScheduleExactAlarms || !_ignoringBatteryOptimizations))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  if (!_canScheduleExactAlarms)
                    _NotificationWarning(
                      icon: Icons.timer_outlined,
                      message: "Exact alarm permission is off. Daily reminders may arrive up to ~15 minutes late.",
                      buttonLabel: "ENABLE",
                      onPressed: () async {
                        await NotificationService().requestExactAlarmsPermission();
                        await _loadSettings();
                      },
                    ),
                  if (!_canScheduleExactAlarms && !_ignoringBatteryOptimizations)
                    const SizedBox(height: 8),
                  if (!_ignoringBatteryOptimizations)
                    _NotificationWarning(
                      icon: Icons.battery_saver_outlined,
                      message: "Battery optimization is on. The system may prevent notifications when the app is closed.",
                      buttonLabel: "FIX NOW",
                      onPressed: () async {
                        await NotificationService().requestIgnoreBatteryOptimizations();
                        await _loadSettings();
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationWarning extends StatelessWidget {
  const _NotificationWarning({
    required this.icon,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: context.colors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onPressed,
                  child: Text(
                    buttonLabel,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
