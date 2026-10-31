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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Trapster'**
  String get appName;

  /// No description provided for @chessTraps.
  ///
  /// In en, this message translates to:
  /// **'Trapster'**
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

  /// No description provided for @openSourceLicense.
  ///
  /// In en, this message translates to:
  /// **'Open source license'**
  String get openSourceLicense;

  /// No description provided for @usedPackages.
  ///
  /// In en, this message translates to:
  /// **'Open-source packages'**
  String get usedPackages;

  /// No description provided for @randomTrap.
  ///
  /// In en, this message translates to:
  /// **'Random trap'**
  String get randomTrap;

  /// No description provided for @yourFavoriteChessTraps.
  ///
  /// In en, this message translates to:
  /// **'Your favorite traps'**
  String get yourFavoriteChessTraps;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @matchingTraps.
  ///
  /// In en, this message translates to:
  /// **'Matching traps'**
  String get matchingTraps;

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
  /// **'{count, plural, =0{No traps saved} =1{1 trap saved} other{{count} traps saved}}'**
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
  /// **'Trapster © 2026'**
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
  /// **'The traps you\'ve saved.'**
  String get yourPersonalCollectionOfTacticalBrilliance;

  /// No description provided for @noFavoriteYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoriteYet;

  /// No description provided for @taptheHeartIconAction.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any trap to save it here.'**
  String get taptheHeartIconAction;

  /// No description provided for @exploreMore.
  ///
  /// In en, this message translates to:
  /// **'Explore more'**
  String get exploreMore;

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

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @browseByOpening.
  ///
  /// In en, this message translates to:
  /// **'Browse by opening'**
  String get browseByOpening;

  /// No description provided for @allTraps.
  ///
  /// In en, this message translates to:
  /// **'All traps'**
  String get allTraps;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @featuredTrap.
  ///
  /// In en, this message translates to:
  /// **'Featured trap'**
  String get featuredTrap;

  /// No description provided for @startTraining.
  ///
  /// In en, this message translates to:
  /// **'Start training'**
  String get startTraining;

  /// No description provided for @unlockedExtraMoves.
  ///
  /// In en, this message translates to:
  /// **'5 more moves unlocked'**
  String get unlockedExtraMoves;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad'**
  String get watchAd;

  /// No description provided for @trapCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trap complete. Well played!'**
  String get trapCompleted;

  /// No description provided for @relatedTraps.
  ///
  /// In en, this message translates to:
  /// **'Related traps'**
  String get relatedTraps;

  /// No description provided for @incorrectMove.
  ///
  /// In en, this message translates to:
  /// **'Not that one. Try again!'**
  String get incorrectMove;

  /// No description provided for @incorrectMoveWithHint.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Here\'s a hint.'**
  String get incorrectMoveWithHint;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @boardTheme.
  ///
  /// In en, this message translates to:
  /// **'Board theme'**
  String get boardTheme;

  /// No description provided for @learnNow.
  ///
  /// In en, this message translates to:
  /// **'Learn now'**
  String get learnNow;

  /// No description provided for @avoidTrap.
  ///
  /// In en, this message translates to:
  /// **'Avoid the trap'**
  String get avoidTrap;

  /// No description provided for @avoidModeActive.
  ///
  /// In en, this message translates to:
  /// **'Avoid mode: find the safe move.'**
  String get avoidModeActive;

  /// No description provided for @blunderPrevented.
  ///
  /// In en, this message translates to:
  /// **'Nice! You avoided the trap.'**
  String get blunderPrevented;

  /// No description provided for @findBetterMove.
  ///
  /// In en, this message translates to:
  /// **'Find a safer move.'**
  String get findBetterMove;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @you_won.
  ///
  /// In en, this message translates to:
  /// **'You won!'**
  String get you_won;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @stockfish_won.
  ///
  /// In en, this message translates to:
  /// **'Stockfish wins'**
  String get stockfish_won;

  /// No description provided for @better_luck_next_time.
  ///
  /// In en, this message translates to:
  /// **'Better luck next time.'**
  String get better_luck_next_time;

  /// No description provided for @you_resigned.
  ///
  /// In en, this message translates to:
  /// **'You resigned'**
  String get you_resigned;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// No description provided for @well_played.
  ///
  /// In en, this message translates to:
  /// **'Well played!'**
  String get well_played;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @play_again.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get play_again;

  /// No description provided for @opponent_strength.
  ///
  /// In en, this message translates to:
  /// **'Opponent strength'**
  String get opponent_strength;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @draws.
  ///
  /// In en, this message translates to:
  /// **'Draws'**
  String get draws;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// No description provided for @play_as.
  ///
  /// In en, this message translates to:
  /// **'Play as'**
  String get play_as;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @start_game.
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get start_game;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get thinking;

  /// No description provided for @your_turn.
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get your_turn;

  /// No description provided for @back_to_setup.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get back_to_setup;

  /// No description provided for @resign.
  ///
  /// In en, this message translates to:
  /// **'Resign'**
  String get resign;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @your_games.
  ///
  /// In en, this message translates to:
  /// **'Your games'**
  String get your_games;

  /// No description provided for @moves.
  ///
  /// In en, this message translates to:
  /// **'moves'**
  String get moves;

  /// No description provided for @first_move.
  ///
  /// In en, this message translates to:
  /// **'First move'**
  String get first_move;

  /// No description provided for @previous_move.
  ///
  /// In en, this message translates to:
  /// **'Previous move'**
  String get previous_move;

  /// No description provided for @next_move.
  ///
  /// In en, this message translates to:
  /// **'Next move'**
  String get next_move;

  /// No description provided for @last_move.
  ///
  /// In en, this message translates to:
  /// **'Last move'**
  String get last_move;

  /// No description provided for @piecePawn.
  ///
  /// In en, this message translates to:
  /// **'pawn'**
  String get piecePawn;

  /// No description provided for @pieceKnight.
  ///
  /// In en, this message translates to:
  /// **'knight'**
  String get pieceKnight;

  /// No description provided for @pieceBishop.
  ///
  /// In en, this message translates to:
  /// **'bishop'**
  String get pieceBishop;

  /// No description provided for @pieceRook.
  ///
  /// In en, this message translates to:
  /// **'rook'**
  String get pieceRook;

  /// No description provided for @pieceQueen.
  ///
  /// In en, this message translates to:
  /// **'queen'**
  String get pieceQueen;

  /// No description provided for @pieceKing.
  ///
  /// In en, this message translates to:
  /// **'king'**
  String get pieceKing;

  /// No description provided for @andSeparator.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andSeparator;

  /// No description provided for @explainCheckmate.
  ///
  /// In en, this message translates to:
  /// **'{piece} delivers checkmate!'**
  String explainCheckmate(String piece);

  /// No description provided for @explainSacrifice.
  ///
  /// In en, this message translates to:
  /// **'Sacrifices {piece} to open up the attack.'**
  String explainSacrifice(String piece);

  /// No description provided for @explainCapture.
  ///
  /// In en, this message translates to:
  /// **'{piece} captures {captured}.'**
  String explainCapture(String piece, String captured);

  /// No description provided for @explainFork.
  ///
  /// In en, this message translates to:
  /// **'{piece} forks {targets}.'**
  String explainFork(String piece, String targets);

  /// No description provided for @explainCheck.
  ///
  /// In en, this message translates to:
  /// **'{piece} gives check, forcing a reply.'**
  String explainCheck(String piece);

  /// No description provided for @explainCastleKingside.
  ///
  /// In en, this message translates to:
  /// **'Castles kingside, tucking the king away safely.'**
  String get explainCastleKingside;

  /// No description provided for @explainCastleQueenside.
  ///
  /// In en, this message translates to:
  /// **'Castles queenside.'**
  String get explainCastleQueenside;

  /// No description provided for @explainPromotion.
  ///
  /// In en, this message translates to:
  /// **'Promotes to a {piece}.'**
  String explainPromotion(String piece);

  /// No description provided for @explainDevelop.
  ///
  /// In en, this message translates to:
  /// **'Develops {piece}.'**
  String explainDevelop(String piece);

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @daily_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached'**
  String get daily_limit_reached;

  /// No description provided for @limit_reached_body.
  ///
  /// In en, this message translates to:
  /// **'That\'s your 10 free traps for today. Watch a short ad to unlock every trap for the rest of the day.'**
  String get limit_reached_body;

  /// No description provided for @no_traps_in_group.
  ///
  /// In en, this message translates to:
  /// **'No traps available for this opening yet.'**
  String get no_traps_in_group;

  /// No description provided for @play_mode.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play_mode;

  /// No description provided for @move_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'Move limit reached and the ad isn\'t ready. Wait a moment or reset the board.'**
  String get move_limit_reached;

  /// No description provided for @search_limit_body.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used your free moves for this search. Watch a short ad to unlock 5 more.'**
  String get search_limit_body;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @daily_trap_reminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get daily_trap_reminder;

  /// No description provided for @daily_trap_reminder_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A nudge to open the trap of the day'**
  String get daily_trap_reminder_subtitle;

  /// No description provided for @reminder_time.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminder_time;

  /// No description provided for @notification_trap_ready_title.
  ///
  /// In en, this message translates to:
  /// **'Today\'s trap is ready'**
  String get notification_trap_ready_title;

  /// No description provided for @notification_trap_ready_body.
  ///
  /// In en, this message translates to:
  /// **'Learn it before your next game ♟️'**
  String get notification_trap_ready_body;

  /// No description provided for @trapNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trap not found'**
  String get trapNotFound;

  /// No description provided for @practiceModeActive.
  ///
  /// In en, this message translates to:
  /// **'Practice mode: play the correct moves.'**
  String get practiceModeActive;

  /// No description provided for @canYouSurvive.
  ///
  /// In en, this message translates to:
  /// **'Could you avoid this trap? Try {trapName}.\n{link}'**
  String canYouSurvive(String trapName, String link);

  /// No description provided for @exitPractice.
  ///
  /// In en, this message translates to:
  /// **'Exit practice'**
  String get exitPractice;

  /// No description provided for @practiceMode.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceMode;

  /// No description provided for @exitAvoidMode.
  ///
  /// In en, this message translates to:
  /// **'Exit avoid mode'**
  String get exitAvoidMode;

  /// No description provided for @avoidTrapMode.
  ///
  /// In en, this message translates to:
  /// **'Avoid the trap'**
  String get avoidTrapMode;

  /// No description provided for @stopAutoPlay.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopAutoPlay;

  /// No description provided for @autoPlay.
  ///
  /// In en, this message translates to:
  /// **'Autoplay'**
  String get autoPlay;

  /// No description provided for @flipBoard.
  ///
  /// In en, this message translates to:
  /// **'Flip board'**
  String get flipBoard;

  /// No description provided for @markedAsLearned.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get markedAsLearned;

  /// No description provided for @markAsLearned.
  ///
  /// In en, this message translates to:
  /// **'Mark as learned'**
  String get markAsLearned;

  /// No description provided for @shareTrap.
  ///
  /// In en, this message translates to:
  /// **'Share trap'**
  String get shareTrap;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @engineStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting engine…'**
  String get engineStarting;

  /// No description provided for @engineUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Engine unavailable'**
  String get engineUnavailable;

  /// No description provided for @depthLabel.
  ///
  /// In en, this message translates to:
  /// **'Depth: {depth}'**
  String depthLabel(int depth);

  /// No description provided for @analysisSettings.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisSettings;

  /// No description provided for @engineBestMoves.
  ///
  /// In en, this message translates to:
  /// **'Engine arrows'**
  String get engineBestMoves;

  /// No description provided for @eloLabel.
  ///
  /// In en, this message translates to:
  /// **'Elo: {elo}'**
  String eloLabel(int elo);

  /// No description provided for @stockfishLabel.
  ///
  /// In en, this message translates to:
  /// **'Stockfish ({elo})'**
  String stockfishLabel(int elo);

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @trapsLearned.
  ///
  /// In en, this message translates to:
  /// **'Traps learned'**
  String get trapsLearned;

  /// No description provided for @learnedProgress.
  ///
  /// In en, this message translates to:
  /// **'{learned} of {total}'**
  String learnedProgress(int learned, int total);

  /// No description provided for @soundAndHaptics.
  ///
  /// In en, this message translates to:
  /// **'Sound & haptics'**
  String get soundAndHaptics;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get hapticFeedback;

  /// No description provided for @vsStockfish.
  ///
  /// In en, this message translates to:
  /// **'vs Stockfish'**
  String get vsStockfish;

  /// No description provided for @vsFriend.
  ///
  /// In en, this message translates to:
  /// **'vs a friend'**
  String get vsFriend;

  /// No description provided for @passAndPlayHint.
  ///
  /// In en, this message translates to:
  /// **'Two players, one phone. Take turns.'**
  String get passAndPlayHint;

  /// No description provided for @whiteWins.
  ///
  /// In en, this message translates to:
  /// **'White wins'**
  String get whiteWins;

  /// No description provided for @blackWins.
  ///
  /// In en, this message translates to:
  /// **'Black wins'**
  String get blackWins;

  /// No description provided for @toMove.
  ///
  /// In en, this message translates to:
  /// **'To move'**
  String get toMove;

  /// No description provided for @opponentResigned.
  ///
  /// In en, this message translates to:
  /// **'Opponent resigned'**
  String get opponentResigned;

  /// No description provided for @gameHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Game history'**
  String get gameHistoryTitle;

  /// No description provided for @allGames.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allGames;

  /// No description provided for @noSavedGames.
  ///
  /// In en, this message translates to:
  /// **'No games saved yet'**
  String get noSavedGames;

  /// No description provided for @viewAllGames.
  ///
  /// In en, this message translates to:
  /// **'View all games'**
  String get viewAllGames;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Trapster'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Learn the openings and catch your opponents with traps that win games.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Play against Stockfish'**
  String get onboardingPlayTitle;

  /// No description provided for @onboardingPlayBody.
  ///
  /// In en, this message translates to:
  /// **'Try your new traps on the board against Stockfish.'**
  String get onboardingPlayBody;

  /// No description provided for @onboardingStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your streak'**
  String get onboardingStreakTitle;

  /// No description provided for @onboardingStreakBody.
  ///
  /// In en, this message translates to:
  /// **'Come back daily to keep your streak alive and save the traps you like.'**
  String get onboardingStreakBody;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @trapForWhite.
  ///
  /// In en, this message translates to:
  /// **'Trap for White'**
  String get trapForWhite;

  /// No description provided for @trapForBlack.
  ///
  /// In en, this message translates to:
  /// **'Trap for Black'**
  String get trapForBlack;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @thePawn.
  ///
  /// In en, this message translates to:
  /// **'the pawn'**
  String get thePawn;

  /// No description provided for @theKnight.
  ///
  /// In en, this message translates to:
  /// **'the knight'**
  String get theKnight;

  /// No description provided for @theBishop.
  ///
  /// In en, this message translates to:
  /// **'the bishop'**
  String get theBishop;

  /// No description provided for @theRook.
  ///
  /// In en, this message translates to:
  /// **'the rook'**
  String get theRook;

  /// No description provided for @theQueen.
  ///
  /// In en, this message translates to:
  /// **'the queen'**
  String get theQueen;

  /// No description provided for @theKing.
  ///
  /// In en, this message translates to:
  /// **'the king'**
  String get theKing;

  /// No description provided for @explainPawnMove.
  ///
  /// In en, this message translates to:
  /// **'Advances {piece}.'**
  String explainPawnMove(String piece);

  /// No description provided for @explainQuietMove.
  ///
  /// In en, this message translates to:
  /// **'Moves {piece}.'**
  String explainQuietMove(String piece);

  /// No description provided for @whiteResigned.
  ///
  /// In en, this message translates to:
  /// **'White resigned'**
  String get whiteResigned;

  /// No description provided for @blackResigned.
  ///
  /// In en, this message translates to:
  /// **'Black resigned'**
  String get blackResigned;

  /// No description provided for @boardThemeBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get boardThemeBrown;

  /// No description provided for @boardThemeBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get boardThemeBlue;

  /// No description provided for @boardThemeGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get boardThemeGreen;

  /// No description provided for @boardThemeWood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get boardThemeWood;

  /// No description provided for @boardThemeWood2.
  ///
  /// In en, this message translates to:
  /// **'Wood II'**
  String get boardThemeWood2;

  /// No description provided for @boardThemeMetal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get boardThemeMetal;

  /// No description provided for @boardThemeMarble.
  ///
  /// In en, this message translates to:
  /// **'Marble'**
  String get boardThemeMarble;

  /// No description provided for @boardThemeHorsey.
  ///
  /// In en, this message translates to:
  /// **'Horsey'**
  String get boardThemeHorsey;

  /// No description provided for @boardThemePurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get boardThemePurple;
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
