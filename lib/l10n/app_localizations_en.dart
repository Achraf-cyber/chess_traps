// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Trapster';

  @override
  String get chessTraps => 'Trapster';

  @override
  String get home => 'Home';

  @override
  String get traps => 'Traps';

  @override
  String get profile => 'Profile';

  @override
  String get trapOfTheDay => 'Trap of the day';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get openSourceLicense => 'Open source license';

  @override
  String get usedPackages => 'Open-source packages';

  @override
  String get randomTrap => 'Random trap';

  @override
  String get yourFavoriteChessTraps => 'Your favorite traps';

  @override
  String get search => 'Search';

  @override
  String get matchingTraps => 'Matching traps';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count traps saved',
      one: '1 trap saved',
      zero: 'No traps saved',
    );
    return '$_temp0';
  }

  @override
  String get appVersion => 'App version';

  @override
  String get profileTitle => 'Chess player';

  @override
  String get copyright => 'Trapster © 2026';

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

  @override
  String get searchByName => 'Search by name';

  @override
  String get yourPersonalCollectionOfTacticalBrilliance =>
      'The traps you\'ve saved.';

  @override
  String get noFavoriteYet => 'No favorites yet';

  @override
  String get taptheHeartIconAction =>
      'Tap the heart on any trap to save it here.';

  @override
  String get exploreMore => 'Explore more';

  @override
  String get theory => 'Theory';

  @override
  String get undo => 'Undo';

  @override
  String get flip => 'Flip';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get browseByOpening => 'Browse by opening';

  @override
  String get allTraps => 'All traps';

  @override
  String get searchResults => 'Search results';

  @override
  String get featuredTrap => 'Featured trap';

  @override
  String get startTraining => 'Start training';

  @override
  String get unlockedExtraMoves => '5 more moves unlocked';

  @override
  String get cancel => 'Cancel';

  @override
  String get watchAd => 'Watch ad';

  @override
  String get trapCompleted => 'Trap complete. Well played!';

  @override
  String get relatedTraps => 'Related traps';

  @override
  String get incorrectMove => 'Not that one. Try again!';

  @override
  String get incorrectMoveWithHint => 'Not quite. Here\'s a hint.';

  @override
  String get goBack => 'Go back';

  @override
  String get boardTheme => 'Board theme';

  @override
  String get learnNow => 'Learn now';

  @override
  String get avoidTrap => 'Avoid the trap';

  @override
  String get avoidModeActive => 'Avoid mode: find the safe move.';

  @override
  String get blunderPrevented => 'Nice! You avoided the trap.';

  @override
  String get findBetterMove => 'Find a safer move.';

  @override
  String get play => 'Play';

  @override
  String get you_won => 'You won!';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get stockfish_won => 'Stockfish wins';

  @override
  String get better_luck_next_time => 'Better luck next time.';

  @override
  String get you_resigned => 'You resigned';

  @override
  String get draw => 'Draw';

  @override
  String get well_played => 'Well played!';

  @override
  String get close => 'Close';

  @override
  String get play_again => 'Play again';

  @override
  String get opponent_strength => 'Opponent strength';

  @override
  String get wins => 'Wins';

  @override
  String get draws => 'Draws';

  @override
  String get losses => 'Losses';

  @override
  String get play_as => 'Play as';

  @override
  String get white => 'White';

  @override
  String get random => 'Random';

  @override
  String get black => 'Black';

  @override
  String get start_game => 'Start game';

  @override
  String get thinking => 'Thinking…';

  @override
  String get your_turn => 'Your turn';

  @override
  String get back_to_setup => 'New game';

  @override
  String get resign => 'Resign';

  @override
  String get hint => 'Hint';

  @override
  String get your_games => 'Your games';

  @override
  String get moves => 'moves';

  @override
  String get first_move => 'First move';

  @override
  String get previous_move => 'Previous move';

  @override
  String get next_move => 'Next move';

  @override
  String get last_move => 'Last move';

  @override
  String get piecePawn => 'pawn';

  @override
  String get pieceKnight => 'knight';

  @override
  String get pieceBishop => 'bishop';

  @override
  String get pieceRook => 'rook';

  @override
  String get pieceQueen => 'queen';

  @override
  String get pieceKing => 'king';

  @override
  String get andSeparator => ' and ';

  @override
  String explainCheckmate(String piece) {
    return '$piece delivers checkmate!';
  }

  @override
  String explainSacrifice(String piece) {
    return 'Sacrifices $piece to open up the attack.';
  }

  @override
  String explainCapture(String piece, String captured) {
    return '$piece captures $captured.';
  }

  @override
  String explainFork(String piece, String targets) {
    return '$piece forks $targets.';
  }

  @override
  String explainCheck(String piece) {
    return '$piece gives check, forcing a reply.';
  }

  @override
  String get explainCastleKingside =>
      'Castles kingside, tucking the king away safely.';

  @override
  String get explainCastleQueenside => 'Castles queenside.';

  @override
  String explainPromotion(String piece) {
    return 'Promotes to a $piece.';
  }

  @override
  String explainDevelop(String piece) {
    return 'Develops $piece.';
  }

  @override
  String get you => 'You';

  @override
  String get daily_limit_reached => 'Daily limit reached';

  @override
  String get limit_reached_body =>
      'That\'s your 10 free traps for today. Watch a short ad to unlock every trap for the rest of the day.';

  @override
  String get no_traps_in_group => 'No traps available for this opening yet.';

  @override
  String get play_mode => 'Play';

  @override
  String get move_limit_reached =>
      'Move limit reached and the ad isn\'t ready. Wait a moment or reset the board.';

  @override
  String get search_limit_body =>
      'You\'ve used your free moves for this search. Watch a short ad to unlock 5 more.';

  @override
  String get notifications => 'Notifications';

  @override
  String get daily_trap_reminder => 'Daily reminder';

  @override
  String get daily_trap_reminder_subtitle =>
      'A nudge to open the trap of the day';

  @override
  String get reminder_time => 'Reminder time';

  @override
  String get notification_trap_ready_title => 'Today\'s trap is ready';

  @override
  String get notification_trap_ready_body =>
      'Learn it before your next game ♟️';

  @override
  String get trapNotFound => 'Trap not found';

  @override
  String get practiceModeActive => 'Practice mode: play the correct moves.';

  @override
  String canYouSurvive(String trapName, String link) {
    return 'Could you avoid this trap? Try $trapName.\n$link';
  }

  @override
  String get exitPractice => 'Exit practice';

  @override
  String get practiceMode => 'Practice';

  @override
  String get exitAvoidMode => 'Exit avoid mode';

  @override
  String get avoidTrapMode => 'Avoid the trap';

  @override
  String get stopAutoPlay => 'Stop';

  @override
  String get autoPlay => 'Autoplay';

  @override
  String get flipBoard => 'Flip board';

  @override
  String get markedAsLearned => 'Learned';

  @override
  String get markAsLearned => 'Mark as learned';

  @override
  String get shareTrap => 'Share trap';

  @override
  String get settings => 'Settings';

  @override
  String get engineStarting => 'Starting engine…';

  @override
  String get engineUnavailable => 'Engine unavailable';

  @override
  String depthLabel(int depth) {
    return 'Depth: $depth';
  }

  @override
  String get analysisSettings => 'Analysis';

  @override
  String get engineBestMoves => 'Engine arrows';

  @override
  String eloLabel(int elo) {
    return 'Elo: $elo';
  }

  @override
  String stockfishLabel(int elo) {
    return 'Stockfish ($elo)';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get trapsLearned => 'Traps learned';

  @override
  String learnedProgress(int learned, int total) {
    return '$learned of $total';
  }

  @override
  String get soundAndHaptics => 'Sound & haptics';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get hapticFeedback => 'Haptic feedback';

  @override
  String get vsStockfish => 'vs Stockfish';

  @override
  String get vsFriend => 'vs a friend';

  @override
  String get passAndPlayHint => 'Two players, one phone. Take turns.';

  @override
  String get whiteWins => 'White wins';

  @override
  String get blackWins => 'Black wins';

  @override
  String get toMove => 'To move';

  @override
  String get opponentResigned => 'Opponent resigned';

  @override
  String get gameHistoryTitle => 'Game history';

  @override
  String get allGames => 'All';

  @override
  String get noSavedGames => 'No games saved yet';

  @override
  String get viewAllGames => 'View all games';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Trapster';

  @override
  String get onboardingWelcomeBody =>
      'Learn the openings and catch your opponents with traps that win games.';

  @override
  String get onboardingPlayTitle => 'Play against Stockfish';

  @override
  String get onboardingPlayBody =>
      'Try your new traps on the board against Stockfish.';

  @override
  String get onboardingStreakTitle => 'Build your streak';

  @override
  String get onboardingStreakBody =>
      'Come back daily to keep your streak alive and save the traps you like.';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get trapForWhite => 'Trap for White';

  @override
  String get trapForBlack => 'Trap for Black';

  @override
  String get language => 'Language';

  @override
  String get thePawn => 'the pawn';

  @override
  String get theKnight => 'the knight';

  @override
  String get theBishop => 'the bishop';

  @override
  String get theRook => 'the rook';

  @override
  String get theQueen => 'the queen';

  @override
  String get theKing => 'the king';

  @override
  String explainPawnMove(String piece) {
    return 'Advances $piece.';
  }

  @override
  String explainQuietMove(String piece) {
    return 'Moves $piece.';
  }

  @override
  String get whiteResigned => 'White resigned';

  @override
  String get blackResigned => 'Black resigned';

  @override
  String get boardThemeBrown => 'Brown';

  @override
  String get boardThemeBlue => 'Blue';

  @override
  String get boardThemeGreen => 'Green';

  @override
  String get boardThemeWood => 'Wood';

  @override
  String get boardThemeWood2 => 'Wood II';

  @override
  String get boardThemeMetal => 'Metal';

  @override
  String get boardThemeMarble => 'Marble';

  @override
  String get boardThemeHorsey => 'Horsey';

  @override
  String get boardThemePurple => 'Purple';
}
