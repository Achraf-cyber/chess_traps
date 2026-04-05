// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authorName => 'Simbre Achraf';

  @override
  String get appName => 'Chess Traps';

  @override
  String get chessTraps => 'Chess Traps';

  @override
  String get home => 'Home';

  @override
  String get traps => 'Traps';

  @override
  String get favorite => 'Favorite';

  @override
  String get training => 'Training';

  @override
  String get profile => 'Profile';

  @override
  String get trapOfTheDay => 'Trap of the day';

  @override
  String get recentTraps => 'Recent Traps';

  @override
  String get exampleTrap => 'Fried Liver Attack';

  @override
  String get lastTimeChecked => 'Last time checked';

  @override
  String get explore => 'Explore';

  @override
  String get viewAllTraps => 'View All Traps';

  @override
  String get errorLoadingTraps => 'Error loading traps';

  @override
  String get noTrapsFound => 'No traps found';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get appLanguage => 'App Language';

  @override
  String get openSourceLicense => 'Open source license';

  @override
  String get usedPackages => 'Packages that were used';

  @override
  String get developer => 'Developer';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get logout => 'Logout';

  @override
  String masteredTraps(Object count, Object percentage) {
    return '$count Mastered traps ($percentage%)';
  }

  @override
  String get english => 'English';

  @override
  String get randomTrap => 'Random Trap';

  @override
  String get yourFavoriteChessTraps => 'You favorite chess traps';

  @override
  String get wildGambit => 'Wild Gambit';

  @override
  String get search => 'Search';

  @override
  String get playTheMoves => 'Play the moves';

  @override
  String get matchingTraps => 'Matching traps';

  @override
  String get playMovesToNarrow => 'Play moves to narrow results';

  @override
  String get resetBoard => 'Reset board';

  @override
  String get noTrapsFoundForSequence => 'No traps found for this sequence';

  @override
  String get appearance => 'Appearance';

  @override
  String get dataManagement => 'Data management';

  @override
  String get about => 'About';

  @override
  String get yourFavorites => 'Your favorites';

  @override
  String favoritesCount(int count) {
    return '$count traps saved';
  }

  @override
  String get appVersion => 'App version';

  @override
  String get profileTitle => 'Chess player';

  @override
  String get copyright => 'Chess Traps © 2026';

  @override
  String get clearFavoritesTitle => 'Clear favorites';

  @override
  String get clearFavoritesHint => 'This cannot be undone';

  @override
  String get clearFavoritesConfirm =>
      'Are you sure you want to remove all saved traps from your favorites?';

  @override
  String get clearFavoritesCancel => 'Cancel';

  @override
  String get clearFavoritesAction => 'Clear all';
}
