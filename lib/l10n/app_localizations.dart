import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @authorName.
  ///
  /// In en, this message translates to:
  /// **'Simbre Achraf'**
  String get authorName;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Chess Traps'**
  String get appName;

  /// No description provided for @chessTraps.
  ///
  /// In en, this message translates to:
  /// **'Chess Traps'**
  String get chessTraps;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @traps.
  ///
  /// In en, this message translates to:
  /// **'Traps'**
  String get traps;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @trapOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Trap of the day'**
  String get trapOfTheDay;

  /// No description provided for @recentTraps.
  ///
  /// In en, this message translates to:
  /// **'Recent Traps'**
  String get recentTraps;

  /// No description provided for @exampleTrap.
  ///
  /// In en, this message translates to:
  /// **'Fried Liver Attack'**
  String get exampleTrap;

  /// No description provided for @lastTimeChecked.
  ///
  /// In en, this message translates to:
  /// **'Last time checked'**
  String get lastTimeChecked;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @viewAllTraps.
  ///
  /// In en, this message translates to:
  /// **'View All Traps'**
  String get viewAllTraps;

  /// No description provided for @errorLoadingTraps.
  ///
  /// In en, this message translates to:
  /// **'Error loading traps'**
  String get errorLoadingTraps;

  /// No description provided for @noTrapsFound.
  ///
  /// In en, this message translates to:
  /// **'No traps found'**
  String get noTrapsFound;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @openSourceLicense.
  ///
  /// In en, this message translates to:
  /// **'Open source license'**
  String get openSourceLicense;

  /// No description provided for @usedPackages.
  ///
  /// In en, this message translates to:
  /// **'Packages that were used'**
  String get usedPackages;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @masteredTraps.
  ///
  /// In en, this message translates to:
  /// **'{count} Mastered traps ({percentage}%)'**
  String masteredTraps(Object count, Object percentage);

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @randomTrap.
  ///
  /// In en, this message translates to:
  /// **'Random Trap'**
  String get randomTrap;

  /// No description provided for @yourFavoriteChessTraps.
  ///
  /// In en, this message translates to:
  /// **'You favorite chess traps'**
  String get yourFavoriteChessTraps;

  /// No description provided for @wildGambit.
  ///
  /// In en, this message translates to:
  /// **'Wild Gambit'**
  String get wildGambit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @playTheMoves.
  ///
  /// In en, this message translates to:
  /// **'Play the moves'**
  String get playTheMoves;

  /// No description provided for @matchingTraps.
  ///
  /// In en, this message translates to:
  /// **'Matching traps'**
  String get matchingTraps;

  /// No description provided for @playMovesToNarrow.
  ///
  /// In en, this message translates to:
  /// **'Play moves to narrow results'**
  String get playMovesToNarrow;

  /// No description provided for @resetBoard.
  ///
  /// In en, this message translates to:
  /// **'Reset board'**
  String get resetBoard;

  /// No description provided for @noTrapsFoundForSequence.
  ///
  /// In en, this message translates to:
  /// **'No traps found for this sequence'**
  String get noTrapsFoundForSequence;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get dataManagement;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @yourFavorites.
  ///
  /// In en, this message translates to:
  /// **'Your favorites'**
  String get yourFavorites;

  /// No description provided for @favoritesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} traps saved'**
  String favoritesCount(int count);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Chess player'**
  String get profileTitle;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Chess Traps © 2026'**
  String get copyright;

  /// No description provided for @clearFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear favorites'**
  String get clearFavoritesTitle;

  /// No description provided for @clearFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone'**
  String get clearFavoritesHint;

  /// No description provided for @clearFavoritesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all saved traps from your favorites?'**
  String get clearFavoritesConfirm;

  /// No description provided for @clearFavoritesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get clearFavoritesCancel;

  /// No description provided for @clearFavoritesAction.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearFavoritesAction;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByName;

  /// No description provided for @yourPersonalCollectionOfTacticalBrilliance.
  ///
  /// In en, this message translates to:
  /// **'Your personal collection of tactical brilliance.'**
  String get yourPersonalCollectionOfTacticalBrilliance;

  /// No description provided for @noFavoriteYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoriteYet;

  /// No description provided for @taptheHeartIconAction.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any trap detail screen to save it here for quick access.'**
  String get taptheHeartIconAction;

  /// No description provided for @elevateYourGame.
  ///
  /// In en, this message translates to:
  /// **'Elevate Your Game'**
  String get elevateYourGame;

  /// No description provided for @discoverWinningSequencesByMasters.
  ///
  /// In en, this message translates to:
  /// **'Discover winning sequences used by masters.'**
  String get discoverWinningSequencesByMasters;

  /// No description provided for @highlight.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlight;

  /// No description provided for @exploreMore.
  ///
  /// In en, this message translates to:
  /// **'Explore More'**
  String get exploreMore;

  /// No description provided for @testYourPatternRecog.
  ///
  /// In en, this message translates to:
  /// **'Test your pattern recognition with a mystery trap.'**
  String get testYourPatternRecog;

  /// No description provided for @strategyGuide.
  ///
  /// In en, this message translates to:
  /// **'Strategy Guide'**
  String get strategyGuide;

  /// No description provided for @comingSoonDeepDives.
  ///
  /// In en, this message translates to:
  /// **'Coming soon: Deep dives into opening theory.'**
  String get comingSoonDeepDives;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @sequenceHistory.
  ///
  /// In en, this message translates to:
  /// **'Sequence History'**
  String get sequenceHistory;

  /// No description provided for @theory.
  ///
  /// In en, this message translates to:
  /// **'Theory'**
  String get theory;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @flip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get flip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
