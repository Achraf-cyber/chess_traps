class EcoRange {
  const EcoRange({required this.start, required this.end});
  final String start;
  final String end;

  bool get isSingle => start == end;

  @override
  String toString() => isSingle ? start : '$start-$end';
}

class OpeningEntry {
  final String id;
  final EcoRange eco;
  final String name;
  final List<String> moves;

  const OpeningEntry({
    required this.id,
    required this.eco,
    required this.name,
    required this.moves,
  });

  String get firstMove => moves.isEmpty ? '' : moves.first;

  @override
  String toString() => '${eco.toString()} $name';
}

class OpeningIndexes {
  final List<OpeningEntry> entries;

  final Map<String, OpeningEntry> byId;
  final Map<String, List<OpeningEntry>> byEcoCode;
  final Map<String, List<OpeningEntry>> byName;
  final Map<String, List<OpeningEntry>> byFirstMove;
  final Map<String, List<OpeningEntry>> byMoveSequence;

  final Map<String, String> ecoCodeToName;
  final Map<String, List<String>> nameToEcoCodes;
  final Map<String, List<String>> firstMoveToIds;

  OpeningIndexes._({
    required this.entries,
    required this.byId,
    required this.byEcoCode,
    required this.byName,
    required this.byFirstMove,
    required this.byMoveSequence,
    required this.ecoCodeToName,
    required this.nameToEcoCodes,
    required this.firstMoveToIds,
  });

  factory OpeningIndexes.build(List<OpeningEntry> entries) {
    final byId = <String, OpeningEntry>{};
    final byEcoCode = <String, List<OpeningEntry>>{};
    final byName = <String, List<OpeningEntry>>{};
    final byFirstMove = <String, List<OpeningEntry>>{};
    final byMoveSequence = <String, List<OpeningEntry>>{};

    final ecoCodeToName = <String, String>{};
    final nameToEcoCodes = <String, List<String>>{};
    final firstMoveToIds = <String, List<String>>{};

    for (final entry in entries) {
      byId[entry.id] = entry;

      final ecoCodes = expandEcoRange(entry.eco);
      for (final code in ecoCodes) {
        byEcoCode.putIfAbsent(code, () => []).add(entry);
        ecoCodeToName[code] = entry.name;
        nameToEcoCodes.putIfAbsent(entry.name, () => []).add(code);
      }

      byName.putIfAbsent(entry.name, () => []).add(entry);

      byFirstMove.putIfAbsent(entry.firstMove, () => []).add(entry);
      firstMoveToIds.putIfAbsent(entry.firstMove, () => []).add(entry.id);

      final moveKey = entry.moves.join(' ');
      byMoveSequence.putIfAbsent(moveKey, () => []).add(entry);
    }

    return OpeningIndexes._(
      entries: entries,
      byId: byId,
      byEcoCode: byEcoCode,
      byName: byName,
      byFirstMove: byFirstMove,
      byMoveSequence: byMoveSequence,
      ecoCodeToName: ecoCodeToName,
      nameToEcoCodes: nameToEcoCodes,
      firstMoveToIds: firstMoveToIds,
    );
  }

  static List<String> expandEcoRange(EcoRange range) {
    final startLetter = range.start[0];
    final endLetter = range.end[0];

    if (startLetter != endLetter) {
      throw ArgumentError('Cross-letter ECO ranges are not supported: $range');
    }

    final startNumber = int.parse(range.start.substring(1));
    final endNumber = int.parse(range.end.substring(1));

    return List<String>.generate(
      endNumber - startNumber + 1,
      (index) =>
          '$startLetter${(startNumber + index).toString().padLeft(2, '0')}',
    );
  }
}

const List<OpeningEntry> ecoOpenings = [
  OpeningEntry(
    id: 'polish_opening',
    eco: EcoRange(start: 'A00', end: 'A00'),
    name: 'Polish (Sokolsky) opening',
    moves: ['b4'],
  ),
  OpeningEntry(
    id: 'nimzovich_larsen_attack',
    eco: EcoRange(start: 'A01', end: 'A01'),
    name: 'Nimzovich-Larsen attack',
    moves: ['b3'],
  ),
  OpeningEntry(
    id: 'birds_opening',
    eco: EcoRange(start: 'A02', end: 'A03'),
    name: "Bird's opening",
    moves: ['f4'],
  ),
  OpeningEntry(
    id: 'reti_opening',
    eco: EcoRange(start: 'A04', end: 'A09'),
    name: 'Reti opening',
    moves: ['Nf3'],
  ),
  OpeningEntry(
    id: 'english_opening',
    eco: EcoRange(start: 'A10', end: 'A39'),
    name: 'English opening',
    moves: ['c4'],
  ),
  OpeningEntry(
    id: 'queens_pawn_a40',
    eco: EcoRange(start: 'A40', end: 'A41'),
    name: "Queen's pawn",
    moves: ['d4'],
  ),
  OpeningEntry(
    id: 'modern_defence_averbakh_system',
    eco: EcoRange(start: 'A42', end: 'A42'),
    name: 'Modern defence, Averbakh system',
    moves: ['d4', 'd6', 'c4', 'g6', 'Nc3', 'Bg7', 'e4'],
  ),
  OpeningEntry(
    id: 'old_benoni_defence',
    eco: EcoRange(start: 'A43', end: 'A44'),
    name: 'Old Benoni defence',
    moves: ['d4', 'c5'],
  ),
  OpeningEntry(
    id: 'queens_pawn_game_a45',
    eco: EcoRange(start: 'A45', end: 'A46'),
    name: "Queen's pawn game",
    moves: ['d4', 'Nf6'],
  ),
  OpeningEntry(
    id: 'queens_indian_defence_a47',
    eco: EcoRange(start: 'A47', end: 'A47'),
    name: "Queen's Indian defence",
    moves: ['d4', 'Nf6', 'Nf3', 'b6'],
  ),
  OpeningEntry(
    id: 'kings_indian_east_indian_defence',
    eco: EcoRange(start: 'A48', end: 'A49'),
    name: "King's Indian, East Indian defence",
    moves: ['d4', 'Nf6', 'Nf3', 'g6'],
  ),
  OpeningEntry(
    id: 'queens_pawn_game_a50',
    eco: EcoRange(start: 'A50', end: 'A50'),
    name: "Queen's pawn game",
    moves: ['d4', 'Nf6', 'c4'],
  ),
  OpeningEntry(
    id: 'budapest_defence',
    eco: EcoRange(start: 'A51', end: 'A52'),
    name: 'Budapest defence',
    moves: ['d4', 'Nf6', 'c4', 'e5'],
  ),
  OpeningEntry(
    id: 'old_indian_defence',
    eco: EcoRange(start: 'A53', end: 'A55'),
    name: 'Old Indian defence',
    moves: ['d4', 'Nf6', 'c4', 'd6'],
  ),
  OpeningEntry(
    id: 'benoni_defence_a56',
    eco: EcoRange(start: 'A56', end: 'A56'),
    name: 'Benoni defence',
    moves: ['d4', 'Nf6', 'c4', 'c5'],
  ),
  OpeningEntry(
    id: 'benko_gambit',
    eco: EcoRange(start: 'A57', end: 'A59'),
    name: 'Benko gambit',
    moves: ['d4', 'Nf6', 'c4', 'c5', 'd5', 'b5'],
  ),
  OpeningEntry(
    id: 'benoni_defence_a60',
    eco: EcoRange(start: 'A60', end: 'A79'),
    name: 'Benoni defence',
    moves: ['d4', 'Nf6', 'c4', 'c5', 'd5', 'e6'],
  ),
  OpeningEntry(
    id: 'dutch',
    eco: EcoRange(start: 'A80', end: 'A99'),
    name: 'Dutch',
    moves: ['d4', 'f5'],
  ),
  OpeningEntry(
    id: 'kings_pawn_opening_b00',
    eco: EcoRange(start: 'B00', end: 'B00'),
    name: "King's pawn opening",
    moves: ['e4'],
  ),
  OpeningEntry(
    id: 'scandinavian_defence',
    eco: EcoRange(start: 'B01', end: 'B01'),
    name: 'Scandinavian (centre counter) defence',
    moves: ['e4', 'd5'],
  ),
  OpeningEntry(
    id: 'alekhines_defence',
    eco: EcoRange(start: 'B02', end: 'B05'),
    name: "Alekhine's defence",
    moves: ['e4', 'Nf6'],
  ),
  OpeningEntry(
    id: 'robatsch_modern_defence',
    eco: EcoRange(start: 'B06', end: 'B06'),
    name: 'Robatsch (modern) defence',
    moves: ['e4', 'g6'],
  ),
  OpeningEntry(
    id: 'pirc_defence',
    eco: EcoRange(start: 'B07', end: 'B09'),
    name: 'Pirc defence',
    moves: ['e4', 'd6', 'd4', 'Nf6', 'Nc3'],
  ),
  OpeningEntry(
    id: 'caro_kann_defence',
    eco: EcoRange(start: 'B10', end: 'B19'),
    name: 'Caro-Kann defence',
    moves: ['e4', 'c6'],
  ),
  OpeningEntry(
    id: 'sicilian_defence',
    eco: EcoRange(start: 'B20', end: 'B99'),
    name: 'Sicilian defence',
    moves: ['e4', 'c5'],
  ),
  OpeningEntry(
    id: 'french_defence',
    eco: EcoRange(start: 'C00', end: 'C19'),
    name: 'French defence',
    moves: ['e4', 'e6'],
  ),
  OpeningEntry(
    id: 'kings_pawn_game_c20',
    eco: EcoRange(start: 'C20', end: 'C20'),
    name: "King's pawn game",
    moves: ['e4', 'e5'],
  ),
  OpeningEntry(
    id: 'centre_game',
    eco: EcoRange(start: 'C21', end: 'C22'),
    name: 'Centre game',
    moves: ['e4', 'e5', 'd4', 'exd4'],
  ),
  OpeningEntry(
    id: 'bishops_opening',
    eco: EcoRange(start: 'C23', end: 'C24'),
    name: "Bishop's opening",
    moves: ['e4', 'e5', 'Bc4'],
  ),
  OpeningEntry(
    id: 'vienna_game',
    eco: EcoRange(start: 'C25', end: 'C29'),
    name: 'Vienna game',
    moves: ['e4', 'e5', 'Nc3'],
  ),
  OpeningEntry(
    id: 'kings_gambit',
    eco: EcoRange(start: 'C30', end: 'C39'),
    name: "King's gambit",
    moves: ['e4', 'e5', 'f4'],
  ),
  OpeningEntry(
    id: 'kings_knight_opening',
    eco: EcoRange(start: 'C40', end: 'C40'),
    name: "King's knight opening",
    moves: ['e4', 'e5', 'Nf3'],
  ),
  OpeningEntry(
    id: 'philidors_defence',
    eco: EcoRange(start: 'C41', end: 'C41'),
    name: "Philidor's defence",
    moves: ['e4', 'e5', 'Nf3', 'd6'],
  ),
  OpeningEntry(
    id: 'petrovs_defence',
    eco: EcoRange(start: 'C42', end: 'C43'),
    name: "Petrov's defence",
    moves: ['e4', 'e5', 'Nf3', 'Nf6'],
  ),
  OpeningEntry(
    id: 'kings_pawn_game_c44',
    eco: EcoRange(start: 'C44', end: 'C44'),
    name: "King's pawn game",
    moves: ['e4', 'e5', 'Nf3', 'Nc6'],
  ),
  OpeningEntry(
    id: 'scotch_game',
    eco: EcoRange(start: 'C45', end: 'C45'),
    name: 'Scotch game',
    moves: ['e4', 'e5', 'Nf3', 'Nc6', 'd4', 'exd4', 'Nxd4'],
  ),
  OpeningEntry(
    id: 'three_knights_game',
    eco: EcoRange(start: 'C46', end: 'C46'),
    name: 'Three knights game',
    moves: ['e4', 'e5', 'Nf3', 'Nc6', 'Nc3'],
  ),
  OpeningEntry(
    id: 'four_knights_scotch_variation',
    eco: EcoRange(start: 'C47', end: 'C49'),
    name: 'Four knights, Scotch variation',
    moves: ['e4', 'e5', 'Nf3', 'Nc6', 'Nc3', 'Nf6', 'd4'],
  ),
  OpeningEntry(
    id: 'italian_game',
    eco: EcoRange(start: 'C50', end: 'C50'),
    name: 'Italian Game',
    moves: ['e4', 'e5', 'Nf3', 'Nc6', 'Bc4'],
  ),
  OpeningEntry(
    id: 'evans_gambit',
    eco: EcoRange(start: 'C51', end: 'C52'),
    name: 'Evans gambit',
    moves: ['e4', 'e5', 'Nf3', 'Nc6', 'Bc4', 'Bc5', 'b4'],
  ),
  OpeningEntry(
    id: 'giuoco_piano',
    eco: EcoRange(start: 'C53', end: 'C54'),
    name: 'Giuoco Piano',
    moves: ['e4', 'e5', 'Nf3', 'Nc6', 'Bc4', 'Bc5', 'c3'],
  ),
  OpeningEntry(
    id: 'two_knights_defence',
    eco: EcoRange(start: 'C55', end: 'C59'),
    name: 'Two knights defence',
    moves: ['e4', 'e5', 'Nf3', 'Nc6', 'Bc4', 'Nf6'],
  ),
  OpeningEntry(
    id: 'ruy_lopez',
    eco: EcoRange(start: 'C60', end: 'C99'),
    name: 'Ruy Lopez (Spanish opening)',
    moves: ['e4', 'e5', 'Nf3', 'Nc6', 'Bb5'],
  ),
  OpeningEntry(
    id: 'queens_pawn_game_d00',
    eco: EcoRange(start: 'D00', end: 'D00'),
    name: "Queen's pawn game",
    moves: ['d4', 'd5'],
  ),
  OpeningEntry(
    id: 'richter_veresov_attack',
    eco: EcoRange(start: 'D01', end: 'D01'),
    name: 'Richter-Veresov attack',
    moves: ['d4', 'd5', 'Nc3', 'Nf6', 'Bg5'],
  ),
  OpeningEntry(
    id: 'queens_pawn_game_d02',
    eco: EcoRange(start: 'D02', end: 'D02'),
    name: "Queen's pawn game",
    moves: ['d4', 'd5', 'Nf3'],
  ),
  OpeningEntry(
    id: 'torre_attack_tartakower_variation',
    eco: EcoRange(start: 'D03', end: 'D03'),
    name: 'Torre attack (Tartakower variation)',
    moves: ['d4', 'd5', 'Nf3', 'Nf6', 'Bg5'],
  ),
  OpeningEntry(
    id: 'queens_pawn_game_d04',
    eco: EcoRange(start: 'D04', end: 'D05'),
    name: "Queen's pawn game",
    moves: ['d4', 'd5', 'Nf3', 'Nf6', 'e3'],
  ),
  OpeningEntry(
    id: 'queens_gambit',
    eco: EcoRange(start: 'D06', end: 'D06'),
    name: "Queen's Gambit",
    moves: ['d4', 'd5', 'c4'],
  ),
  OpeningEntry(
    id: 'qgd_chigorin_defence',
    eco: EcoRange(start: 'D07', end: 'D09'),
    name: "Queen's Gambit Declined, Chigorin defence",
    moves: ['d4', 'd5', 'c4', 'Nc6'],
  ),
  OpeningEntry(
    id: 'qgd_slav_defence',
    eco: EcoRange(start: 'D10', end: 'D15'),
    name: "Queen's Gambit Declined Slav defence",
    moves: ['d4', 'd5', 'c4', 'c6'],
  ),
  OpeningEntry(
    id: 'qgd_slav_accepted_alapin_variation',
    eco: EcoRange(start: 'D16', end: 'D16'),
    name: "Queen's Gambit Declined Slav accepted, Alapin variation",
    moves: ['d4', 'd5', 'c4', 'c6', 'Nf3', 'Nf6', 'Nc3', 'dxc4', 'a4'],
  ),
  OpeningEntry(
    id: 'qgd_slav_czech_defence',
    eco: EcoRange(start: 'D17', end: 'D19'),
    name: "Queen's Gambit Declined Slav, Czech defence",
    moves: ['d4', 'd5', 'c4', 'c6', 'Nf3', 'Nf6', 'Nc3', 'dxc4', 'a4', 'Bf5'],
  ),
  OpeningEntry(
    id: 'queens_gambit_accepted',
    eco: EcoRange(start: 'D20', end: 'D29'),
    name: "Queen's gambit accepted",
    moves: ['d4', 'd5', 'c4', 'dxc4'],
  ),
  OpeningEntry(
    id: 'queens_gambit_declined',
    eco: EcoRange(start: 'D30', end: 'D42'),
    name: "Queen's gambit declined",
    moves: ['d4', 'd5', 'c4', 'e6'],
  ),
  OpeningEntry(
    id: 'qgd_semi_slav',
    eco: EcoRange(start: 'D43', end: 'D49'),
    name: "Queen's Gambit Declined semi-Slav",
    moves: ['d4', 'd5', 'c4', 'e6', 'Nc3', 'Nf6', 'Nf3', 'c6'],
  ),
  OpeningEntry(
    id: 'qgd_4_bg5',
    eco: EcoRange(start: 'D50', end: 'D69'),
    name: "Queen's Gambit Declined, 4.Bg5",
    moves: ['d4', 'd5', 'c4', 'e6', 'Nc3', 'Nf6', 'Bg5'],
  ),
  OpeningEntry(
    id: 'neo_gruenfeld_defence',
    eco: EcoRange(start: 'D70', end: 'D79'),
    name: 'Neo-Gruenfeld defence',
    moves: ['d4', 'Nf6', 'c4', 'g6', 'f3', 'd5'],
  ),
  OpeningEntry(
    id: 'gruenfeld_defence',
    eco: EcoRange(start: 'D80', end: 'D99'),
    name: 'Gruenfeld defence',
    moves: ['d4', 'Nf6', 'c4', 'g6', 'Nc3', 'd5'],
  ),
  OpeningEntry(
    id: 'queens_pawn_game_e00',
    eco: EcoRange(start: 'E00', end: 'E00'),
    name: "Queen's pawn game",
    moves: ['d4', 'Nf6', 'c4', 'e6'],
  ),
  OpeningEntry(
    id: 'catalan_closed',
    eco: EcoRange(start: 'E01', end: 'E09'),
    name: 'Catalan, closed',
    moves: ['d4', 'Nf6', 'c4', 'e6', 'g3', 'd5', 'Bg2'],
  ),
  OpeningEntry(
    id: 'queens_pawn_game_e10',
    eco: EcoRange(start: 'E10', end: 'E10'),
    name: "Queen's pawn game",
    moves: ['d4', 'Nf6', 'c4', 'e6', 'Nf3'],
  ),
  OpeningEntry(
    id: 'bogo_indian_defence',
    eco: EcoRange(start: 'E11', end: 'E11'),
    name: 'Bogo-Indian defence',
    moves: ['d4', 'Nf6', 'c4', 'e6', 'Nf3', 'Bb4+'],
  ),
  OpeningEntry(
    id: 'queens_indian_defence_e12',
    eco: EcoRange(start: 'E12', end: 'E19'),
    name: "Queen's Indian defence",
    moves: ['d4', 'Nf6', 'c4', 'e6', 'Nf3', 'b6'],
  ),
  OpeningEntry(
    id: 'nimzo_indian_defence',
    eco: EcoRange(start: 'E20', end: 'E59'),
    name: 'Nimzo-Indian defence',
    moves: ['d4', 'Nf6', 'c4', 'e6', 'Nc3', 'Bb4'],
  ),
  OpeningEntry(
    id: 'kings_indian_defence',
    eco: EcoRange(start: 'E60', end: 'E99'),
    name: "King's Indian defence",
    moves: ['d4', 'Nf6', 'c4', 'g6'],
  ),
];

final OpeningIndexes ecoOpeningIndexes = OpeningIndexes.build(ecoOpenings);
