import 'package:chess_traps/providers/favorites_provider.dart';
import 'package:chess_traps/providers/theme_provider.dart';
import 'package:chess_traps/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final ThemeNotifier themeNotifier = ref.read(themeProvider.notifier);
    final favoritesCount = ref.watch(favoritesProvider).length;

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
              ref.read(favoritesProvider.notifier).clear();
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
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: context.colors.primary,
                    child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    context.phrase.profileTitle,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
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
  final ThemeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.outlineVariant.withValues(alpha: 0.3)),
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
              Icon(icon, color: isSelected ? context.colors.onPrimary : context.colors.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isSelected ? context.colors.onPrimary : context.colors.onSurfaceVariant,
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
            border: Border.all(color: context.colors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? context.colors.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    if (subtitle != null)
                      Text(subtitle!, style: context.textTheme.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: context.colors.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }
}
