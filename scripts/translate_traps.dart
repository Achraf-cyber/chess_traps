import 'dart:io';

/// A script that adds translation headers (Event_fr, Event_es, Event_ar) to PGN files
/// using a hardcoded translation map for the 50 well-known traps, and
/// "White vs Black" naming for the 700 miniatures collection.
///
/// No API key needed.
void main() async {
  final trapsDir = Directory('data/chess traps');
  if (!await trapsDir.exists()) {
    stderr.writeln('Folder not found: ${trapsDir.path}');
    return;
  }

  final pgnFiles = await trapsDir
      .list()
      .where((e) => e is File && e.path.toLowerCase().endsWith('.pgn'))
      .cast<File>()
      .toList();

  for (final file in pgnFiles) {
    stdout.writeln('Processing: ${file.path}');
    await _processFile(file);
  }

  stdout.writeln('\n✅ All PGN files processed successfully!');
}

Future<void> _processFile(File file) async {
  final content = await file.readAsString();
  final games = _splitPgnIntoGames(content).toList();
  if (games.isEmpty) return;

  final filename = file.uri.pathSegments.last.toLowerCase();
  final isMinisFile = filename.contains('g700');

  final newContent = StringBuffer();
  int renamed = 0;

  for (var gameStr in games) {
    // Extract headers
    final eventMatch = RegExp(r'\[Event\s+"([^"]+)"\]').firstMatch(gameStr);
    final eventName = eventMatch?.group(1) ?? '';
    final whiteMatch = RegExp(r'\[White\s+"([^"]+)"\]').firstMatch(gameStr);
    final blackMatch = RegExp(r'\[Black\s+"([^"]+)"\]').firstMatch(gameStr);
    final chapterMatch = RegExp(r'\[ChapterName\s+"([^"]+)"\]').firstMatch(gameStr);

    // Skip if translations already exist
    if (gameStr.contains('[Event_fr')) {
      newContent.writeln(gameStr);
      newContent.writeln();
      continue;
    }

    String displayName = chapterMatch?.group(1) ?? eventName;

    // For the miniatures file, build a meaningful name from player names
    if (isMinisFile) {
      final white = whiteMatch?.group(1) ?? '';
      final black = blackMatch?.group(1) ?? '';
      // Only rename if the current Event is a generic location name
      if (_isGenericEventName(eventName) && white.isNotEmpty && black.isNotEmpty) {
        displayName = '$white vs $black';
        // Update the Event header
        gameStr = gameStr.replaceFirst(
          RegExp(r'\[Event\s+"([^"]+)"\]'),
          '[Event "$displayName"]',
        );
        renamed++;
      }
    }

    // Get translations
    final translations = _getTranslations(displayName);

    // Inject translation tags right after the Event header
    final translationTags =
        '\n[Event_fr "${translations['fr']}"]\n[Event_es "${translations['es']}"]\n[Event_ar "${translations['ar']}"]';
    gameStr = gameStr.replaceFirstMapped(
      RegExp(r'\[Event\s+"[^"]+"\]'),
      (match) => '${match.group(0)}$translationTags',
    );

    newContent.writeln(gameStr);
    newContent.writeln();
  }

  await file.writeAsString(newContent.toString().trim() + '\n');
  stdout.writeln('  ✓ ${games.length} games processed ($renamed renamed)');
}

bool _isGenericEventName(String name) {
  final generic = {
    'corr.', 'corr', 'internet', 'europe', 'germany', 'usa',
    'france', 'england', 'copenhagen', 'st. petersburg', 'vienna',
    'berlin', 'london', 'paris', 'budapest', 'moscow', 'new york',
    'amsterdam', 'hastings', 'zürich', 'zurich', '?', '',
    'casual', 'rapid', 'blitz', 'simul', 'exhibition',
  };
  return generic.contains(name.toLowerCase().trim());
}

Map<String, String> _getTranslations(String name) {
  // Check the hardcoded map first
  final key = name.toLowerCase().trim();
  if (_translationMap.containsKey(key)) {
    return _translationMap[key]!;
  }

  // For names like "White vs Black", translate the "vs"
  if (name.contains(' vs ')) {
    return {
      'fr': name.replaceFirst(' vs ', ' contre '),
      'es': name.replaceFirst(' vs ', ' contra '),
      'ar': name.replaceFirst(' vs ', ' ضد '),
    };
  }

  // For chess term patterns, do partial translations
  String fr = name, es = name, ar = name;
  for (final entry in _termTranslations.entries) {
    fr = fr.replaceAll(entry.key, entry.value['fr']!);
    es = es.replaceAll(entry.key, entry.value['es']!);
    ar = ar.replaceAll(entry.key, entry.value['ar']!);
  }

  return {'fr': fr, 'es': es, 'ar': ar};
}

/// Common chess terms and their translations
final _termTranslations = {
  'Trap': {'fr': 'Piège', 'es': 'Trampa', 'ar': 'فخ'},
  'Gambit': {'fr': 'Gambit', 'es': 'Gambito', 'ar': 'غامبيت'},
  'Attack': {'fr': 'Attaque', 'es': 'Ataque', 'ar': 'هجوم'},
  'Defense': {'fr': 'Défense', 'es': 'Defensa', 'ar': 'دفاع'},
  'Mate': {'fr': 'Mat', 'es': 'Mate', 'ar': 'كش ملك'},
  'Checkmate': {'fr': 'Échec et mat', 'es': 'Jaque mate', 'ar': 'كش ملك'},
  'Opening': {'fr': 'Ouverture', 'es': 'Apertura', 'ar': 'افتتاحية'},
  'Counterattack': {'fr': 'Contre-attaque', 'es': 'Contraataque', 'ar': 'هجوم مضاد'},
  'Variation': {'fr': 'Variante', 'es': 'Variante', 'ar': 'تنويعة'},
  'Smothered': {'fr': 'Étouffé', 'es': 'Ahogado', 'ar': 'مخنوق'},
};

/// Hardcoded translations for the 50 well-known traps
final _translationMap = <String, Map<String, String>>{
  // 1-ai-studio.pgn traps
  "1. scholar's mate trap": {
    'fr': '1. Piège du Mat du Berger',
    'es': '1. Trampa del Mate del Pastor',
    'ar': '1. فخ مات الراعي',
  },
  "2. fool's mate trap": {
    'fr': "2. Piège du Mat de l'Idiot",
    'es': '2. Trampa del Mate del Loco',
    'ar': '2. فخ مات الأحمق',
  },
  "3. legal's mate trap": {
    'fr': '3. Piège du Mat de Légal',
    'es': '3. Trampa del Mate de Légal',
    'ar': '3. فخ مات ليجال',
  },
  "4. blackburne shilling gambit trap": {
    'fr': '4. Piège du Gambit Blackburne-Shilling',
    'es': '4. Trampa del Gambito Blackburne-Shilling',
    'ar': '4. فخ غامبيت بلاكبيرن شيلنغ',
  },
  "5. tennison gambit (icbm) trap": {
    'fr': '5. Piège du Gambit Tennison (ICBM)',
    'es': '5. Trampa del Gambito Tennison (ICBM)',
    'ar': '5. فخ غامبيت تينيسون',
  },
  "6. englund gambit trap": {
    'fr': '6. Piège du Gambit Englund',
    'es': '6. Trampa del Gambito Englund',
    'ar': '6. فخ غامبيت إنجلوند',
  },
  "7. fishing pole trap": {
    'fr': '7. Piège de la Canne à Pêche',
    'es': '7. Trampa de la Caña de Pescar',
    'ar': '7. فخ صنارة الصيد',
  },
  "8. elephant trap": {
    'fr': "8. Piège de l'Éléphant",
    'es': '8. Trampa del Elefante',
    'ar': '8. فخ الفيل',
  },
  "9. lasker trap": {
    'fr': '9. Piège de Lasker',
    'es': '9. Trampa de Lasker',
    'ar': '9. فخ لاسكر',
  },
  "10. rubinstein trap": {
    'fr': '10. Piège de Rubinstein',
    'es': '10. Trampa de Rubinstein',
    'ar': '10. فخ روبنشتاين',
  },
  "11. siberian trap": {
    'fr': '11. Piège Sibérien',
    'es': '11. Trampa Siberiana',
    'ar': '11. الفخ السيبيري',
  },
  "12. mortimer trap": {
    'fr': '12. Piège de Mortimer',
    'es': '12. Trampa de Mortimer',
    'ar': '12. فخ مورتيمر',
  },
  "13. noah's ark trap": {
    'fr': "13. Piège de l'Arche de Noé",
    'es': '13. Trampa del Arca de Noé',
    'ar': '13. فخ سفينة نوح',
  },
  "14. tarrasch trap": {
    'fr': '14. Piège de Tarrasch',
    'es': '14. Trampa de Tarrasch',
    'ar': '14. فخ تاراش',
  },
  "15. halosar trap": {
    'fr': '15. Piège Halosar',
    'es': '15. Trampa Halosar',
    'ar': '15. فخ هالوسار',
  },
  "16. kieninger trap": {
    'fr': '16. Piège de Kieninger',
    'es': '16. Trampa de Kieninger',
    'ar': '16. فخ كينينغر',
  },
  "17. monticelli trap": {
    'fr': '17. Piège de Monticelli',
    'es': '17. Trampa de Monticelli',
    'ar': '17. فخ مونتيتشيلي',
  },
  "18. stafford gambit trap": {
    'fr': '18. Piège du Gambit Stafford',
    'es': '18. Trampa del Gambito Stafford',
    'ar': '18. فخ غامبيت ستافورد',
  },
  "19. giuoco piano trap": {
    'fr': '19. Piège du Giuoco Piano',
    'es': '19. Trampa del Giuoco Piano',
    'ar': '19. فخ جيوكو بيانو',
  },
  "20. rousseau gambit trap": {
    'fr': '20. Piège du Gambit Rousseau',
    'es': '20. Trampa del Gambito Rousseau',
    'ar': '20. فخ غامبيت روسو',
  },
  "21. jerome gambit trap": {
    'fr': '21. Piège du Gambit Jerome',
    'es': '21. Trampa del Gambito Jerome',
    'ar': '21. فخ غامبيت جيروم',
  },
  "22. nakhmanson gambit trap": {
    'fr': '22. Piège du Gambit Nakhmanson',
    'es': '22. Trampa del Gambito Nakhmanson',
    'ar': '22. فخ غامبيت ناخمانسون',
  },
  "23. danish gambit trap": {
    'fr': '23. Piège du Gambit Danois',
    'es': '23. Trampa del Gambito Danés',
    'ar': '23. فخ الغامبيت الدنماركي',
  },
  "24. o'kelly trap": {
    'fr': "24. Piège d'O'Kelly",
    'es': "24. Trampa de O'Kelly",
    'ar': '24. فخ أوكيلي',
  },
  "25. magnus smith trap": {
    'fr': '25. Piège de Magnus Smith',
    'es': '25. Trampa de Magnus Smith',
    'ar': '25. فخ ماغنوس سميث',
  },
  "26. caro-kann smyslov trap": {
    'fr': '26. Piège Caro-Kann Smyslov',
    'es': '26. Trampa Caro-Kann Smyslov',
    'ar': '26. فخ كارو كان سميسلوف',
  },
  "27. caro-kann advance trap": {
    'fr': '27. Piège Caro-Kann Avance',
    'es': '27. Trampa Caro-Kann Avance',
    'ar': '27. فخ كارو كان المتقدم',
  },
  "28. french milner-barry trap": {
    'fr': '28. Piège Française Milner-Barry',
    'es': '28. Trampa Francesa Milner-Barry',
    'ar': '28. فخ الفرنسية ميلنر باري',
  },
  "29. pirc austrian attack trap": {
    'fr': "29. Piège de l'Attaque Autrichienne Pirc",
    'es': '29. Trampa del Ataque Austriaco Pirc',
    'ar': '29. فخ الهجوم النمساوي بيرك',
  },
  "30. philidor hanham trap": {
    'fr': '30. Piège Philidor Hanham',
    'es': '30. Trampa Philidor Hanham',
    'ar': '30. فخ فيليدور هانهام',
  },
  "31. muzio gambit trap": {
    'fr': '31. Piège du Gambit Muzio',
    'es': '31. Trampa del Gambito Muzio',
    'ar': '31. فخ غامبيت موزيو',
  },
  "32. kieseritzky gambit trap": {
    'fr': '32. Piège du Gambit Kieseritzky',
    'es': '32. Trampa del Gambito Kieseritzky',
    'ar': '32. فخ غامبيت كيزيريتسكي',
  },
  "33. evans gambit trap": {
    'fr': '33. Piège du Gambit Evans',
    'es': '33. Trampa del Gambito Evans',
    'ar': '33. فخ غامبيت إيفانز',
  },
  "34. benoni trap": {
    'fr': '34. Piège Benoni',
    'es': '34. Trampa Benoni',
    'ar': '34. فخ بنوني',
  },
  "35. kortchnoi trap (dutch defense)": {
    'fr': '35. Piège de Kortchnoï (Défense Hollandaise)',
    'es': '35. Trampa de Korchnoi (Defensa Holandesa)',
    'ar': '35. فخ كورتشنوي (الدفاع الهولندي)',
  },
  "36. reti opening trap": {
    'fr': "36. Piège de l'Ouverture Réti",
    'es': '36. Trampa de la Apertura Réti',
    'ar': '36. فخ افتتاحية ريتي',
  },
  "37. from's gambit trap": {
    'fr': '37. Piège du Gambit From',
    'es': '37. Trampa del Gambito From',
    'ar': '37. فخ غامبيت فروم',
  },
  "38. fried liver attack trap": {
    'fr': '38. Piège de l\'Attaque du Foie Frit',
    'es': '38. Trampa del Ataque del Hígado Frito',
    'ar': '38. فخ هجوم الكبد المقلي',
  },
  "39. traxler counterattack trap": {
    'fr': '39. Piège de la Contre-attaque Traxler',
    'es': '39. Trampa del Contraataque Traxler',
    'ar': '39. فخ الهجوم المضاد تراكسلر',
  },
  "40. owen's defense trap": {
    'fr': "40. Piège de la Défense Owen",
    'es': '40. Trampa de la Defensa Owen',
    'ar': '40. فخ دفاع أوين',
  },
  "41. queen's gambit accepted trap": {
    'fr': '41. Piège du Gambit Dame Accepté',
    'es': '41. Trampa del Gambito de Dama Aceptado',
    'ar': '41. فخ غامبيت الملكة المقبول',
  },
  "42. frankenstein-dracula trap": {
    'fr': '42. Piège Frankenstein-Dracula',
    'es': '42. Trampa Frankenstein-Drácula',
    'ar': '42. فخ فرانكنشتاين دراكولا',
  },
  "43. fajarowicz trap (budapest gambit)": {
    'fr': '43. Piège de Fajarowicz (Gambit Budapest)',
    'es': '43. Trampa de Fajarowicz (Gambito Budapest)',
    'ar': '43. فخ فاياروفيتش (غامبيت بودابست)',
  },
  "44. englund gambit complex trap": {
    'fr': '44. Piège du Gambit Englund Complexe',
    'es': '44. Trampa del Gambito Englund Complejo',
    'ar': '44. فخ غامبيت إنجلوند المعقد',
  },
  "45. würzburger trap (vienna game)": {
    'fr': '45. Piège de Würzburg (Partie Viennoise)',
    'es': '45. Trampa de Würzburg (Partida Vienesa)',
    'ar': '45. فخ فورتسبورغ (لعبة فيينا)',
  },
  "46. budapest gambit adler trap": {
    'fr': '46. Piège Adler du Gambit Budapest',
    'es': '46. Trampa Adler del Gambito Budapest',
    'ar': '46. فخ أدلر غامبيت بودابست',
  },
  "47. marshall trap (petrov's defense)": {
    'fr': '47. Piège de Marshall (Défense Petroff)',
    'es': '47. Trampa de Marshall (Defensa Petrov)',
    'ar': '47. فخ مارشال (دفاع بتروف)',
  },
  "48. alapin sicilian trap": {
    'fr': '48. Piège Sicilienne Alapine',
    'es': '48. Trampa Siciliana Alapin',
    'ar': '48. فخ الصقلية ألابين',
  },
  "49. krejcik trap (dutch defense)": {
    'fr': '49. Piège de Krejcik (Défense Hollandaise)',
    'es': '49. Trampa de Krejcik (Defensa Holandesa)',
    'ar': '49. فخ كريتشيك (الدفاع الهولندي)',
  },
  "50. two knights trap": {
    'fr': '50. Piège des Deux Cavaliers',
    'es': '50. Trampa de los Dos Caballos',
    'ar': '50. فخ الحصانين',
  },
};

Iterable<String> _splitPgnIntoGames(String pgnFileContents) sync* {
  final normalized = pgnFileContents.replaceAll('\r\n', '\n').trim();
  if (normalized.isEmpty) return;

  final parts = normalized.split(RegExp(r'(?=\[Event\s+")'));
  for (final part in parts) {
    final chunk = part.trim();
    if (chunk.isEmpty) continue;
    if (!chunk.startsWith('[Event')) continue;
    yield chunk;
  }
}
