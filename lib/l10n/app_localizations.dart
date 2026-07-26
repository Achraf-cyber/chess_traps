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

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @browseByOpening.
  ///
  /// In en, this message translates to:
  /// **'Browse by Opening'**
  String get browseByOpening;

  /// No description provided for @allTraps.
  ///
  /// In en, this message translates to:
  /// **'All Traps'**
  String get allTraps;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @featuredTrap.
  ///
  /// In en, this message translates to:
  /// **'Featured Trap'**
  String get featuredTrap;

  /// No description provided for @startTraining.
  ///
  /// In en, this message translates to:
  /// **'Start Training'**
  String get startTraining;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @unlockedExtraMoves.
  ///
  /// In en, this message translates to:
  /// **'Unlocked 5 extra moves!'**
  String get unlockedExtraMoves;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get limitReached;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'WATCH AD'**
  String get watchAd;

  /// No description provided for @trapCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trap completed! Well done!'**
  String get trapCompleted;

  /// No description provided for @relatedTraps.
  ///
  /// In en, this message translates to:
  /// **'Related traps'**
  String get relatedTraps;

  /// No description provided for @incorrectMove.
  ///
  /// In en, this message translates to:
  /// **'Incorrect move. Try again!'**
  String get incorrectMove;

  /// No description provided for @incorrectMoveWithHint.
  ///
  /// In en, this message translates to:
  /// **'Not quite — here\'s a hint.'**
  String get incorrectMoveWithHint;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @boardTheme.
  ///
  /// In en, this message translates to:
  /// **'Board Theme'**
  String get boardTheme;

  /// No description provided for @learnNow.
  ///
  /// In en, this message translates to:
  /// **'Learn Now'**
  String get learnNow;

  /// No description provided for @avoidTrap.
  ///
  /// In en, this message translates to:
  /// **'Avoid the Trap'**
  String get avoidTrap;

  /// No description provided for @avoidModeActive.
  ///
  /// In en, this message translates to:
  /// **'Avoid Mode active. Find the best move!'**
  String get avoidModeActive;

  /// No description provided for @blunderPrevented.
  ///
  /// In en, this message translates to:
  /// **'Great! You avoided the trap.'**
  String get blunderPrevented;

  /// No description provided for @findBetterMove.
  ///
  /// In en, this message translates to:
  /// **'Find a better move to avoid the trap.'**
  String get findBetterMove;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @you_won.
  ///
  /// In en, this message translates to:
  /// **'You Won! 🎉'**
  String get you_won;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @stockfish_won.
  ///
  /// In en, this message translates to:
  /// **'Stockfish Won'**
  String get stockfish_won;

  /// No description provided for @better_luck_next_time.
  ///
  /// In en, this message translates to:
  /// **'Better luck next time!'**
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
  /// **'Play Again'**
  String get play_again;

  /// No description provided for @opponent_strength.
  ///
  /// In en, this message translates to:
  /// **'Opponent Strength'**
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

  /// No description provided for @engine_response.
  ///
  /// In en, this message translates to:
  /// **'Engine Response'**
  String get engine_response;

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
  /// **'Start Game'**
  String get start_game;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @your_turn.
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get your_turn;

  /// No description provided for @back_to_setup.
  ///
  /// In en, this message translates to:
  /// **'Back to Setup'**
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

  /// No description provided for @choose_promotion.
  ///
  /// In en, this message translates to:
  /// **'Promote to'**
  String get choose_promotion;

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
  /// **'Sacrifices the {piece} to open up the attack.'**
  String explainSacrifice(String piece);

  /// No description provided for @explainCapture.
  ///
  /// In en, this message translates to:
  /// **'The {piece} captures the {captured}.'**
  String explainCapture(String piece, String captured);

  /// No description provided for @explainFork.
  ///
  /// In en, this message translates to:
  /// **'The {piece} forks {targets}.'**
  String explainFork(String piece, String targets);

  /// No description provided for @explainCheck.
  ///
  /// In en, this message translates to:
  /// **'The {piece} gives check, forcing a reply.'**
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
  /// **'Develops the {piece}.'**
  String explainDevelop(String piece);

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @featured_trap.
  ///
  /// In en, this message translates to:
  /// **'Featured Trap'**
  String get featured_trap;

  /// No description provided for @loading_ads.
  ///
  /// In en, this message translates to:
  /// **'Loading ads...'**
  String get loading_ads;

  /// No description provided for @daily_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached'**
  String get daily_limit_reached;

  /// No description provided for @ad_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Ad could not be loaded. Try again later.'**
  String get ad_load_failed;

  /// No description provided for @ad_not_ready.
  ///
  /// In en, this message translates to:
  /// **'Ad not ready yet. Try again later.'**
  String get ad_not_ready;

  /// No description provided for @limit_reached_body.
  ///
  /// In en, this message translates to:
  /// **'You\'ve viewed your 10 free traps for today! Watch a short ad to unlock all traps for the rest of the day.'**
  String get limit_reached_body;

  /// No description provided for @no_traps_in_group.
  ///
  /// In en, this message translates to:
  /// **'No traps available for this opening yet.'**
  String get no_traps_in_group;

  /// No description provided for @surprise_me.
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get surprise_me;

  /// No description provided for @play_mode.
  ///
  /// In en, this message translates to:
  /// **'Play Mode'**
  String get play_mode;

  /// No description provided for @vs_engine.
  ///
  /// In en, this message translates to:
  /// **'vs Engine'**
  String get vs_engine;

  /// No description provided for @by_moves.
  ///
  /// In en, this message translates to:
  /// **'By Moves'**
  String get by_moves;

  /// No description provided for @find_by_position.
  ///
  /// In en, this message translates to:
  /// **'Find by position'**
  String get find_by_position;

  /// No description provided for @traps_count.
  ///
  /// In en, this message translates to:
  /// **'{count} traps'**
  String traps_count(Object count);

  /// No description provided for @opening_traps_count.
  ///
  /// In en, this message translates to:
  /// **'{count} Opening Traps'**
  String opening_traps_count(Object count);

  /// No description provided for @hero_title.
  ///
  /// In en, this message translates to:
  /// **'Outplay Your\nOpponent'**
  String get hero_title;

  /// No description provided for @hero_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Master the traps that grandmasters use.'**
  String get hero_subtitle;

  /// No description provided for @openings.
  ///
  /// In en, this message translates to:
  /// **'Openings'**
  String get openings;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @move_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'Move limit reached. Ad not ready yet, please wait or reset.'**
  String get move_limit_reached;

  /// No description provided for @search_limit_body.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the free move limit for this search. Watch a short video ad to unlock 5 more moves.'**
  String get search_limit_body;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @daily_trap_reminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Trap Reminder'**
  String get daily_trap_reminder;

  /// No description provided for @daily_trap_reminder_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified to check the trap of the day'**
  String get daily_trap_reminder_subtitle;

  /// No description provided for @reminder_time.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminder_time;

  /// No description provided for @notification_trap_ready_title.
  ///
  /// In en, this message translates to:
  /// **'Trap of the Day is Ready!'**
  String get notification_trap_ready_title;

  /// No description provided for @notification_trap_ready_body.
  ///
  /// In en, this message translates to:
  /// **'Jump in to learn a new opening trap and boost your rating ♟️'**
  String get notification_trap_ready_body;

  /// No description provided for @trapNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trap not found'**
  String get trapNotFound;

  /// No description provided for @practiceModeActive.
  ///
  /// In en, this message translates to:
  /// **'Practice mode active. Play the correct moves!'**
  String get practiceModeActive;

  /// No description provided for @canYouSurvive.
  ///
  /// In en, this message translates to:
  /// **'Can you survive this trap? Check out {trapName}!\n{link}'**
  String canYouSurvive(String trapName, String link);

  /// No description provided for @exitPractice.
  ///
  /// In en, this message translates to:
  /// **'Exit Practice'**
  String get exitPractice;

  /// No description provided for @practiceMode.
  ///
  /// In en, this message translates to:
  /// **'Practice Mode'**
  String get practiceMode;

  /// No description provided for @exitAvoidMode.
  ///
  /// In en, this message translates to:
  /// **'Exit Avoid Mode'**
  String get exitAvoidMode;

  /// No description provided for @avoidTrapMode.
  ///
  /// In en, this message translates to:
  /// **'Avoid Trap Mode'**
  String get avoidTrapMode;

  /// No description provided for @stopAutoPlay.
  ///
  /// In en, this message translates to:
  /// **'Stop Auto Play'**
  String get stopAutoPlay;

  /// No description provided for @autoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto Play'**
  String get autoPlay;

  /// No description provided for @flipBoard.
  ///
  /// In en, this message translates to:
  /// **'Flip Board'**
  String get flipBoard;

  /// No description provided for @markedAsLearned.
  ///
  /// In en, this message translates to:
  /// **'Marked as learned'**
  String get markedAsLearned;

  /// No description provided for @markAsLearned.
  ///
  /// In en, this message translates to:
  /// **'Mark as learned'**
  String get markAsLearned;

  /// No description provided for @shareTrap.
  ///
  /// In en, this message translates to:
  /// **'Share Trap'**
  String get shareTrap;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @engineStarting.
  ///
  /// In en, this message translates to:
  /// **'Engine starting...'**
  String get engineStarting;

  /// No description provided for @whiteProfits.
  ///
  /// In en, this message translates to:
  /// **'Advantage for White'**
  String get whiteProfits;

  /// No description provided for @blackProfits.
  ///
  /// In en, this message translates to:
  /// **'Advantage for Black'**
  String get blackProfits;

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
  /// **'Analysis Settings'**
  String get analysisSettings;

  /// No description provided for @engineBestMoves.
  ///
  /// In en, this message translates to:
  /// **'Engine Best Moves (Arrows)'**
  String get engineBestMoves;

  /// No description provided for @eloLabel.
  ///
  /// In en, this message translates to:
  /// **'Elo: {elo}'**
  String eloLabel(int elo);

  /// No description provided for @engineResponseLabel.
  ///
  /// In en, this message translates to:
  /// **'Engine Response: {delay}s avg'**
  String engineResponseLabel(String delay);

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

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String streakDays(int count);

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

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games played'**
  String get gamesPlayed;

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
  /// **'vs Friend'**
  String get vsFriend;

  /// No description provided for @passAndPlayHint.
  ///
  /// In en, this message translates to:
  /// **'Pass and play on one device — take turns with a friend.'**
  String get passAndPlayHint;

  /// No description provided for @whiteWins.
  ///
  /// In en, this message translates to:
  /// **'White wins!'**
  String get whiteWins;

  /// No description provided for @blackWins.
  ///
  /// In en, this message translates to:
  /// **'Black wins!'**
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
