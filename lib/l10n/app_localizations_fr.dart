// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get authorName => 'Simbre Achraf';

  @override
  String get appName => 'Pièges d\'échecs';

  @override
  String get chessTraps => 'Pièges d\'échecs';

  @override
  String get home => 'Accueil';

  @override
  String get traps => 'Pièges';

  @override
  String get favorite => 'Favoris';

  @override
  String get training => 'Entraînement';

  @override
  String get profile => 'Profil';

  @override
  String get trapOfTheDay => 'Piège du jour';

  @override
  String get recentTraps => 'Pièges récents';

  @override
  String get exampleTrap => 'Attaque Fried Liver';

  @override
  String get lastTimeChecked => 'Dernière consultation';

  @override
  String get explore => 'Explorer';

  @override
  String get viewAllTraps => 'Voir tous les pièges';

  @override
  String get errorLoadingTraps => 'Erreur lors du chargement des pièges';

  @override
  String get noTrapsFound => 'Aucun piège trouvé';

  @override
  String get theme => 'Thème';

  @override
  String get system => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get appLanguage => 'Langue de l\'application';

  @override
  String get openSourceLicense => 'Licence open source';

  @override
  String get usedPackages => 'Packages utilisés';

  @override
  String get developer => 'Développeur';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get logout => 'Déconnexion';

  @override
  String masteredTraps(Object count, Object percentage) {
    return '$count Pièges maîtrisés ($percentage%)';
  }

  @override
  String get english => 'Anglais';
}
