// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get authorName => 'Simbre Achraf';

  @override
  String get appName => 'Celadas de Ajedrez';

  @override
  String get chessTraps => 'Celadas de Ajedrez';

  @override
  String get home => 'Inicio';

  @override
  String get traps => 'Celadas';

  @override
  String get favorite => 'Favorito';

  @override
  String get training => 'Entrenamiento';

  @override
  String get profile => 'Perfil';

  @override
  String get trapOfTheDay => 'Celada del día';

  @override
  String get recentTraps => 'Celadas recientes';

  @override
  String get exampleTrap => 'Ataque Fried Liver';

  @override
  String get lastTimeChecked => 'Última vez verificado';

  @override
  String get explore => 'Explorar';

  @override
  String get viewAllTraps => 'Ver todas las celadas';

  @override
  String get errorLoadingTraps => 'Error al cargar las celadas';

  @override
  String get noTrapsFound => 'No se encontraron celadas';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get appLanguage => 'Idioma de la aplicación';

  @override
  String get openSourceLicense => 'Licencia de código abierto';

  @override
  String get usedPackages => 'Paquetes que se utilizaron';

  @override
  String get developer => 'Desarrollador';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String masteredTraps(Object count, Object percentage) {
    return '$count Celadas dominadas ($percentage%)';
  }

  @override
  String get english => 'Inglés';

  @override
  String get randomTrap => 'Celada aleatoria';

  @override
  String get yourFavoriteChessTraps => 'Tus celadas de ajedrez favoritas';

  @override
  String get wildGambit => 'Gambito salvaje';

  @override
  String get search => 'Buscar';

  @override
  String get playTheMoves => 'Juega las jugadas';

  @override
  String get matchingTraps => 'Celadas coincidentes';

  @override
  String get playMovesToNarrow => 'Juega movimientos para acotar resultados';

  @override
  String get resetBoard => 'Reiniciar tablero';

  @override
  String get noTrapsFoundForSequence =>
      'No se encontraron celadas para esta secuencia';

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
    return '$count celadas guardadas';
  }

  @override
  String get appVersion => 'Versión de la app';

  @override
  String get profileTitle => 'Jugador de ajedrez';

  @override
  String get copyright => 'Celadas de Ajedrez © 2026';

  @override
  String get clearFavoritesTitle => 'Borrar favoritos';

  @override
  String get clearFavoritesHint => 'Esto no se puede deshacer';

  @override
  String get clearFavoritesConfirm =>
      '¿Seguro que deseas eliminar todas las celadas guardadas de favoritos?';

  @override
  String get clearFavoritesCancel => 'Cancelar';

  @override
  String get clearFavoritesAction => 'Borrar todo';
}
