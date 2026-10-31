// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Trapster';

  @override
  String get chessTraps => 'Trapster';

  @override
  String get home => 'Inicio';

  @override
  String get traps => 'Trampas';

  @override
  String get profile => 'Perfil';

  @override
  String get trapOfTheDay => 'Trampa del día';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get openSourceLicense => 'Licencia de código abierto';

  @override
  String get usedPackages => 'Paquetes de código abierto';

  @override
  String get randomTrap => 'Trampa al azar';

  @override
  String get yourFavoriteChessTraps => 'Tus trampas favoritas';

  @override
  String get search => 'Buscar';

  @override
  String get matchingTraps => 'Trampas coincidentes';

  @override
  String get resetBoard => 'Reiniciar tablero';

  @override
  String get noTrapsFoundForSequence =>
      'No se encontraron trampas para esta secuencia';

  @override
  String get appearance => 'Apariencia';

  @override
  String get dataManagement => 'Gestión de datos';

  @override
  String get about => 'Acerca de';

  @override
  String get yourFavorites => 'Tus favoritos';

  @override
  String favoritesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trampas guardadas',
      one: '1 trampa guardada',
      zero: 'Ninguna trampa guardada',
    );
    return '$_temp0';
  }

  @override
  String get appVersion => 'Versión de la app';

  @override
  String get profileTitle => 'Jugador de ajedrez';

  @override
  String get copyright => 'Trapster © 2026';

  @override
  String get clearFavoritesTitle => 'Borrar favoritos';

  @override
  String get clearFavoritesHint => 'Esto no se puede deshacer';

  @override
  String get clearFavoritesConfirm =>
      '¿Seguro que deseas eliminar todas las trampas guardadas de favoritos?';

  @override
  String get clearFavoritesCancel => 'Cancelar';

  @override
  String get clearFavoritesAction => 'Borrar todo';

  @override
  String get searchByName => 'Buscar por nombre';

  @override
  String get yourPersonalCollectionOfTacticalBrilliance =>
      'Las trampas que has guardado.';

  @override
  String get noFavoriteYet => 'Aún no hay favoritos';

  @override
  String get taptheHeartIconAction =>
      'Toca el corazón de una trampa para guardarla aquí.';

  @override
  String get exploreMore => 'Explorar más';

  @override
  String get theory => 'Teoría';

  @override
  String get undo => 'Deshacer';

  @override
  String get flip => 'Girar';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get browseByOpening => 'Explorar por apertura';

  @override
  String get allTraps => 'Todas las trampas';

  @override
  String get searchResults => 'Resultados de búsqueda';

  @override
  String get featuredTrap => 'Trampa destacada';

  @override
  String get startTraining => 'Empezar a entrenar';

  @override
  String get unlockedExtraMoves => '5 jugadas más desbloqueadas';

  @override
  String get cancel => 'Cancelar';

  @override
  String get watchAd => 'Ver anuncio';

  @override
  String get trapCompleted => 'Trampa completada. ¡Bien jugado!';

  @override
  String get relatedTraps => 'Trampas relacionadas';

  @override
  String get incorrectMove => 'Esa no es. ¡Inténtalo de nuevo!';

  @override
  String get incorrectMoveWithHint => 'Casi. Aquí tienes una pista.';

  @override
  String get goBack => 'Volver';

  @override
  String get boardTheme => 'Tema del tablero';

  @override
  String get learnNow => 'Aprender ahora';

  @override
  String get avoidTrap => 'Evita la trampa';

  @override
  String get avoidModeActive => 'Modo evitar: encuentra la jugada segura.';

  @override
  String get blunderPrevented => '¡Bien! Evitaste la trampa.';

  @override
  String get findBetterMove => 'Busca una jugada más segura.';

  @override
  String get play => 'Jugar';

  @override
  String get you_won => '¡Has ganado!';

  @override
  String get congratulations => '¡Felicidades!';

  @override
  String get stockfish_won => 'Gana Stockfish';

  @override
  String get better_luck_next_time => 'A la próxima será.';

  @override
  String get you_resigned => 'Te has rendido';

  @override
  String get draw => 'Tablas';

  @override
  String get well_played => '¡Bien jugado!';

  @override
  String get close => 'Cerrar';

  @override
  String get play_again => 'Jugar otra vez';

  @override
  String get opponent_strength => 'Fuerza del rival';

  @override
  String get wins => 'Victorias';

  @override
  String get draws => 'Tablas';

  @override
  String get losses => 'Derrotas';

  @override
  String get play_as => 'Jugar con';

  @override
  String get white => 'Blancas';

  @override
  String get random => 'Aleatorio';

  @override
  String get black => 'Negras';

  @override
  String get start_game => 'Empezar partida';

  @override
  String get thinking => 'Pensando…';

  @override
  String get your_turn => 'Tu turno';

  @override
  String get back_to_setup => 'Nueva partida';

  @override
  String get resign => 'Abandonar';

  @override
  String get hint => 'Pista';

  @override
  String get your_games => 'Tus partidas';

  @override
  String get moves => 'jugadas';

  @override
  String get first_move => 'Primera jugada';

  @override
  String get previous_move => 'Jugada anterior';

  @override
  String get next_move => 'Jugada siguiente';

  @override
  String get last_move => 'Última jugada';

  @override
  String get piecePawn => 'peón';

  @override
  String get pieceKnight => 'caballo';

  @override
  String get pieceBishop => 'alfil';

  @override
  String get pieceRook => 'torre';

  @override
  String get pieceQueen => 'dama';

  @override
  String get pieceKing => 'rey';

  @override
  String get andSeparator => ' y ';

  @override
  String explainCheckmate(String piece) {
    return '¡$piece da jaque mate!';
  }

  @override
  String explainSacrifice(String piece) {
    return 'Sacrifica $piece para abrir el ataque.';
  }

  @override
  String explainCapture(String piece, String captured) {
    return '$piece captura $captured.';
  }

  @override
  String explainFork(String piece, String targets) {
    return '$piece hace una horquilla sobre $targets.';
  }

  @override
  String explainCheck(String piece) {
    return '$piece da jaque, forzando una respuesta.';
  }

  @override
  String get explainCastleKingside => 'Enroca corto, poniendo al rey a salvo.';

  @override
  String get explainCastleQueenside => 'Enroca largo.';

  @override
  String explainPromotion(String piece) {
    return 'Corona a $piece.';
  }

  @override
  String explainDevelop(String piece) {
    return 'Desarrolla $piece.';
  }

  @override
  String get you => 'Tú';

  @override
  String get daily_limit_reached => 'Límite diario alcanzado';

  @override
  String get limit_reached_body =>
      'Ya viste tus 10 trampas gratis de hoy. Mira un anuncio corto para desbloquearlas todas hasta mañana.';

  @override
  String get no_traps_in_group =>
      'Aún no hay trampas disponibles para esta apertura.';

  @override
  String get play_mode => 'Jugar';

  @override
  String get move_limit_reached =>
      'Límite de jugadas alcanzado y el anuncio no está listo. Espera o reinicia el tablero.';

  @override
  String get search_limit_body =>
      'Has usado tus jugadas gratis en esta búsqueda. Mira un anuncio corto para desbloquear 5 más.';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get daily_trap_reminder => 'Recordatorio diario';

  @override
  String get daily_trap_reminder_subtitle =>
      'Un aviso para ver la trampa del día';

  @override
  String get reminder_time => 'Hora del recordatorio';

  @override
  String get notification_trap_ready_title => 'La trampa de hoy está lista';

  @override
  String get notification_trap_ready_body =>
      'Apréndela antes de tu próxima partida ♟️';

  @override
  String get trapNotFound => 'Trampa no encontrada';

  @override
  String get practiceModeActive =>
      'Modo práctica: juega las jugadas correctas.';

  @override
  String canYouSurvive(String trapName, String link) {
    return '¿Evitarías esta trampa? Prueba $trapName.\n$link';
  }

  @override
  String get exitPractice => 'Salir de la práctica';

  @override
  String get practiceMode => 'Práctica';

  @override
  String get exitAvoidMode => 'Salir del modo evitar';

  @override
  String get avoidTrapMode => 'Evita la trampa';

  @override
  String get stopAutoPlay => 'Detener';

  @override
  String get autoPlay => 'Reproducir';

  @override
  String get flipBoard => 'Girar tablero';

  @override
  String get markedAsLearned => 'Aprendida';

  @override
  String get markAsLearned => 'Marcar como aprendida';

  @override
  String get shareTrap => 'Compartir trampa';

  @override
  String get settings => 'Ajustes';

  @override
  String get engineStarting => 'Iniciando motor…';

  @override
  String get engineUnavailable => 'Motor no disponible';

  @override
  String depthLabel(int depth) {
    return 'Profundidad: $depth';
  }

  @override
  String get analysisSettings => 'Análisis';

  @override
  String get engineBestMoves => 'Flechas del motor';

  @override
  String eloLabel(int elo) {
    return 'Elo: $elo';
  }

  @override
  String stockfishLabel(int elo) {
    return 'Stockfish ($elo)';
  }

  @override
  String get statistics => 'Estadísticas';

  @override
  String get currentStreak => 'Racha actual';

  @override
  String get trapsLearned => 'Trampas aprendidas';

  @override
  String learnedProgress(int learned, int total) {
    return '$learned de $total';
  }

  @override
  String get soundAndHaptics => 'Sonido y vibración';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get hapticFeedback => 'Respuesta háptica';

  @override
  String get vsStockfish => 'contra Stockfish';

  @override
  String get vsFriend => 'contra un amigo';

  @override
  String get passAndPlayHint => 'Dos jugadores, un móvil. Por turnos.';

  @override
  String get whiteWins => 'Ganan las blancas';

  @override
  String get blackWins => 'Ganan las negras';

  @override
  String get toMove => 'Juegan';

  @override
  String get opponentResigned => 'El rival se rindió';

  @override
  String get gameHistoryTitle => 'Historial de partidas';

  @override
  String get allGames => 'Todas';

  @override
  String get noSavedGames => 'Aún no hay partidas guardadas';

  @override
  String get viewAllGames => 'Ver todas las partidas';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingWelcomeTitle => 'Te damos la bienvenida a Trapster';

  @override
  String get onboardingWelcomeBody =>
      'Aprende las aperturas y atrapa a tus rivales.';

  @override
  String get onboardingPlayTitle => 'Juega contra Stockfish';

  @override
  String get onboardingPlayBody =>
      'Prueba tus nuevas trampas contra Stockfish.';

  @override
  String get onboardingStreakTitle => 'Mantén tu racha';

  @override
  String get onboardingStreakBody =>
      'Vuelve cada día para mantener tu racha y guarda tus trampas favoritas.';

  @override
  String get removeFromFavorites => 'Quitar de favoritos';

  @override
  String get trapForWhite => 'Trampa para las blancas';

  @override
  String get trapForBlack => 'Trampa para las negras';

  @override
  String get language => 'Idioma';

  @override
  String get thePawn => 'el peón';

  @override
  String get theKnight => 'el caballo';

  @override
  String get theBishop => 'el alfil';

  @override
  String get theRook => 'la torre';

  @override
  String get theQueen => 'la dama';

  @override
  String get theKing => 'el rey';

  @override
  String explainPawnMove(String piece) {
    return 'Avanza $piece.';
  }

  @override
  String explainQuietMove(String piece) {
    return 'Mueve $piece.';
  }

  @override
  String get whiteResigned => 'Las blancas se rindieron';

  @override
  String get blackResigned => 'Las negras se rindieron';

  @override
  String get boardThemeBrown => 'Marrón';

  @override
  String get boardThemeBlue => 'Azul';

  @override
  String get boardThemeGreen => 'Verde';

  @override
  String get boardThemeWood => 'Madera';

  @override
  String get boardThemeWood2 => 'Madera II';

  @override
  String get boardThemeMetal => 'Metal';

  @override
  String get boardThemeMarble => 'Mármol';

  @override
  String get boardThemeHorsey => 'Horsey';

  @override
  String get boardThemePurple => 'Morado';
}
