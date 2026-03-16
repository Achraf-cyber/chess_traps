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
  String get randomTrap => 'Random Trap';
}
