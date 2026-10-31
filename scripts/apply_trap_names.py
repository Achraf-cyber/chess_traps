"""Gives every trap in base_chess_traps.dart its real name, in all languages.

    python scripts/apply_trap_names.py <dir with lichess chess-openings *.tsv>

Replaces the scraped study titles and the tournament places that had ended up
in the translations. A name is built from, in order:

  1. a named trap, recognised from its moves (SIGNATURES);
  2. a named trap already in the data (PROPER, e.g. "Monticelli Trap");
  3. the opening or variation, by the longest match in the lichess database;

followed by what the trap does (MOTIFS). Traps that would still share a name
are told apart by their decisive move.

base_chess_traps.dart is generated: run this again after regenerating it, and
then scripts/generate_chess_tries.dart for the search index.
"""
import collections, glob, json, os, re, sys

FILE = 'lib/generated/chess/base_chess_traps.dart'

# name: (fr, es, ar). Moves are SAN; every listed move must occur in order.
SIGNATURES = [
    (('Nf3', 'Bg4', 'Nxe5', 'Bxd1', 'Bxf7+', 'Ke7', 'Nd5#'), "Legal's Mate"),
    (('e4', 'e5', 'Nf3', 'Nc6', 'Bc4', 'Nf6', 'Ng5', 'Bc5'), 'Traxler Counterattack'),
    (('e4', 'e5', 'Nf3', 'Nc6', 'Bc4', 'Nf6', 'Ng5', 'd5', 'exd5', 'Nxd5', 'Nxf7'), 'Fried Liver Attack'),
    (('e4', 'e5', 'Nf3', 'Nc6', 'Bc4', 'Nd4'), 'Blackburne Shilling Gambit'),
    (('e4', 'e5', 'Nf3', 'Nf6', 'Nxe5', 'Nc6'), 'Stafford Gambit'),
    (('d4', 'Nf6', 'c4', 'e5', 'dxe5', 'Ng4', 'Bf4', 'Nc6', 'Nf3', 'Bb4+', 'Nbd2', 'Qe7', 'a3', 'Ngxe5', 'axb4', 'Nd3#'), 'Kieninger Trap'),
    (('d4', 'd5', 'c4', 'e5', 'dxe5', 'd4', 'e3', 'Bb4+', 'Bd2', 'dxe3'), 'Lasker Trap'),
    (('d4', 'd5', 'c4', 'e6', 'Nc3', 'Nf6', 'Bg5', 'Nbd7', 'cxd5', 'exd5', 'Nxd5', 'Nxd5', 'Bxd8', 'Bb4+'), 'Elephant Trap'),
    (('e4', 'e5', 'Nf3', 'Nc6', 'Bb5', 'Nf6', 'O-O', 'Ng4', 'h3', 'h5'), 'Fishing Pole Trap'),
    (('d4', 'e5', 'dxe5', 'Nc6', 'Nf3', 'Qe7', 'Bf4', 'Qb4+'), 'Englund Gambit Trap'),
    (('e4', 'c6', 'd4', 'd5', 'Nc3', 'dxe4', 'Nxe4', 'Nd7', 'Qe2', 'Ngf6', 'Nd6#'), 'Caro-Kann Smothered Mate'),
    (('e4', 'e5', 'Qh5', 'Nc6', 'Bc4', 'Nf6', 'Qxf7#'), "Scholar's Mate"),
    (('e4', 'e5', 'Bc4', 'Nc6', 'Qh5', 'Nf6', 'Qxf7#'), "Scholar's Mate"),
    (('f3', 'e5', 'g4', 'Qh4#'), "Fool's Mate"),
    (('f3', 'e6', 'g4', 'Qh4#'), "Fool's Mate"),
]

# Recognised in an existing title; the part of the title that is the real name.
PROPER = [
    "Scholar's Mate", "Fool's Mate", "Legal's Mate", 'Blackburne Shilling Gambit',
    'Fishing Pole', 'Elephant', 'Lasker', 'Rubinstein', 'Siberian', 'Mortimer',
    "Noah's Ark", 'Tarrasch', 'Halosar', 'Kieninger', 'Monticelli', 'Stafford Gambit',
    'Rousseau Gambit', 'Jerome Gambit', 'Nakhmanson Gambit', 'Danish Gambit', "O'Kelly",
    'Magnus Smith', 'Muzio Gambit', 'Kieseritzky Gambit', 'Evans Gambit', 'Fried Liver Attack',
    'Traxler', 'Frankenstein-Dracula', 'Fajarowicz', 'Würzburger', 'Marshall', 'Krejcik',
    'Kortchnoi', 'Cambridge Springs', 'Max Lange Attack',
    "Anastasia's Mate", 'Englund Gambit', 'Tennison Gambit', 'Fischer', "From's Gambit",
    'Milner-Barry', 'Smyslov',
]

# Translated real names; a name not here keeps its surname, which is the same
# word in every language but Arabic.
KNOWN = {
    "Scholar's Mate": ('Coup du berger', 'Mate del pastor', 'كش مات الراعي'),
    "Fool's Mate": ('Mat du fou', 'Mate del loco', 'كش مات الأحمق'),
    "Legal's Mate": ('Mat de Légal', 'Mate de Legal', 'كش مات ليغال'),
    'Fried Liver Attack': ('Attaque du foie frit', 'Ataque del hígado frito', 'هجوم الكبد المقلي'),
    'Traxler Counterattack': ('Contre-attaque Traxler', 'Contraataque Traxler', 'هجوم تراكسلر المضاد'),
    'Blackburne Shilling Gambit': ('Gambit Blackburne-Shilling', 'Gambito Blackburne-Shilling', 'مناورة بلاكبيرن شيلينغ'),
    'Stafford Gambit': ('Gambit Stafford', 'Gambito Stafford', 'مناورة ستافورد'),
    'Kieninger Trap': ('Piège Kieninger', 'Trampa Kieninger', 'فخ كينينغر'),
    'Lasker Trap': ('Piège de Lasker', 'Trampa de Lasker', 'فخ لاسكر'),
    'Elephant Trap': ("Piège de l'éléphant", 'Trampa del elefante', 'فخ الفيل'),
    'Fishing Pole Trap': ('Piège de la canne à pêche', 'Trampa de la caña de pescar', 'فخ صنارة الصيد'),
    'Englund Gambit Trap': ('Piège du gambit Englund', 'Trampa del gambito Englund', 'فخ مناورة إنغلوند'),
    'Caro-Kann Smothered Mate': ('Mat étouffé de la Caro-Kann', 'Mate ahogado de la Caro-Kann', 'الكش مات الخانق في كارو-كان'),
    "Noah's Ark Trap": ("Piège de l'arche de Noé", 'Trampa del arca de Noé', 'فخ سفينة نوح'),
    'Siberian Trap': ('Piège sibérien', 'Trampa siberiana', 'الفخ السيبيري'),
    "Anastasia's Mate": ("Mat d'Anastasia", 'Mate de Anastasia', 'كش مات أناستازيا'),
}

# Surnames and places in named traps and gambits, for Arabic titles.
AR_NAMES = {
    'Tarrasch': 'تاراش', 'Rubinstein': 'روبنشتاين', 'Mortimer': 'مورتيمر', 'Halosar': 'هالوسار',
    'Monticelli': 'مونتيتشيلي', "O'Kelly": 'أوكيلي', 'Magnus Smith': 'ماغنوس سميث',
    'Krejcik': 'كريتشيك', 'Kortchnoi': 'كورتشنوي', 'Marshall': 'مارشال', 'Fajarowicz': 'فاياروفيتش',
    'Würzburger': 'فورتسبورغر', 'Cambridge Springs': 'كامبريدج سبرينغز', 'Fischer': 'فيشر',
    'Smyslov': 'سميسلوف', 'Milner-Barry': 'ميلنر-باري', 'Frankenstein-Dracula': 'فرانكشتاين-دراكولا',
}
AR_GAMBITS = {
    'Rousseau Gambit': 'مناورة روسو', 'Jerome Gambit': 'مناورة جيروم', 'Nakhmanson Gambit': 'مناورة ناخمانسون',
    'Muzio Gambit': 'مناورة موزيو', 'Kieseritzky Gambit': 'مناورة كيزيريتسكي', "From's Gambit": 'مناورة فروم',
    'Max Lange Attack': 'هجوم ماكس لانغه', 'Budapest Gambit Adler': 'مناورة بودابست',
}

# Variations named with an ordinary word rather than a name.
PLAIN_VARIATIONS = {
    'Exchange Variation': ("variante d'échange", 'variante del cambio'),
    'Classical Variation': ('variante classique', 'variante clásica'),
    'Classical Attack': ('attaque classique', 'ataque clásico'),
    'Central Variation': ('variante centrale', 'variante central'),
    'Alapin Opening': ('ouverture Alapin', 'apertura Alapin'),
    'Three Knights Game': ('partie des trois cavaliers', 'partida de los tres caballos'),
    'Classical Defense': ('défense classique', 'defensa clásica'),
    'Modern Variation': ('variante moderne', 'variante moderna'),
    'Modern Defense': ('défense moderne', 'defensa moderna'),
    'Advance Variation': ("variante d'avance", 'variante del avance'),
    'Closed Variation': ('variante fermée', 'variante cerrada'),
    'Open Variation': ('variante ouverte', 'variante abierta'),
    'Symmetrical Variation': ('variante symétrique', 'variante simétrica'),
    'Accelerated Dragon': ('dragon accéléré', 'dragón acelerado'),
    'Dragon Variation': ('variante du dragon', 'variante del dragón'),
    'Old Variation': ('ancienne variante', 'variante antigua'),
    'Fianchetto Variation': ('variante du fianchetto', 'variante del fianchetto'),
    'Fianchetto Defense': ('défense du fianchetto', 'defensa del fianchetto'),
}

# Says nothing: the title is better off with just the family.
EMPTY_VARIATIONS = ('Normal Variation', 'Main Line', 'Mainline Variation', 'Other Variations')

SAN_PIECES = {'fr': str.maketrans('QRBN', 'DTFC'), 'es': str.maketrans('QRBN', 'DTAC')}

# English title: (fr, es, ar).
MOTIFS = {
    'Wins a Pawn': ('Gain de pion', 'Ganancia de peón', 'كسب بيدق'),
    'Wins a Piece': ('Gain de pièce', 'Ganancia de pieza', 'كسب قطعة'),
    'Wins the Exchange': ("Gain de la qualité", 'Ganancia de calidad', 'كسب الجودة'),
    'Wins the Queen': ('Gain de la dame', 'Ganancia de la dama', 'كسب الوزير'),
    'Back-Rank Mate': ('Mat du couloir', 'Mate del pasillo', 'كش مات الصف الأخير'),
    'Smothered Mate': ('Mat étouffé', 'Mate ahogado', 'الكش مات الخانق'),
    'Bishop Mate': ('Mat au fou', 'Mate de alfil', 'كش مات بالفيل'),
    'Knight Mate': ('Mat au cavalier', 'Mate de caballo', 'كش مات بالحصان'),
    'Queen Mate': ('Mat à la dame', 'Mate de dama', 'كش مات بالوزير'),
    'Pawn Mate': ('Mat au pion', 'Mate de peón', 'كش مات بالبيدق'),
    'Rook Mate': ('Mat à la tour', 'Mate de torre', 'كش مات بالرخ'),
    'Checkmate': ('Échec et mat', 'Jaque mate', 'كش مات'),
    'Knight Fork': ('Fourchette de cavalier', 'Horquilla de caballo', 'شوكة الحصان'),
    'Queen Trap': ('Piège à la dame', 'Trampa a la dama', 'فخ الوزير'),
    'Promotion Trap': ('Piège de promotion', 'Trampa de promoción', 'فخ الترقية'),
    'Trap': ('piège', 'trampa', 'فخ'),
}

PIECES = {
    'B': ('Bishop', 'du fou', 'de alfil', 'بالفيل'),
    'N': ('Knight', 'du cavalier', 'de caballo', 'بالحصان'),
}

# Opening family, as lichess writes it: (fr, es, ar).
FAMILIES = {
    "Alekhine Defense": ('Défense Alekhine', 'Defensa Alekhine', 'دفاع أليخين'),
    "Alapin's Opening": ('Ouverture Alapin', 'Apertura Alapin', 'افتتاح ألابين'),
    "Amar Opening": ('Ouverture Amar', 'Apertura Amar', 'افتتاح أمار'),
    "Benko Gambit": ('Gambit Benko', 'Gambito Benko', 'مناورة بينكو'),
    "Benoni Defense": ('Défense Benoni', 'Defensa Benoni', 'دفاع بينوني'),
    "Bird Opening": ('Ouverture Bird', 'Apertura Bird', 'افتتاح بيرد'),
    "Bishop's Opening": ('Ouverture du fou', 'Apertura de alfil', 'افتتاح الفيل'),
    "Blackmar-Diemer Gambit": ('Gambit Blackmar-Diemer', 'Gambito Blackmar-Diemer', 'مناورة بلاكمار-ديمر'),
    "Budapest Defense": ('Gambit de Budapest', 'Gambito Budapest', 'مناورة بودابست'),
    "Caro-Kann Defense": ('Défense Caro-Kann', 'Defensa Caro-Kann', 'دفاع كارو-كان'),
    "Center Game": ('Partie du centre', 'Apertura central', 'لعبة المركز'),
    "Catalan Opening": ('Ouverture catalane', 'Apertura catalana', 'الافتتاح الكتالوني'),
    "Danish Gambit": ('Gambit danois', 'Gambito danés', 'المناورة الدنماركية'),
    "Dutch Defense": ('Défense hollandaise', 'Defensa holandesa', 'الدفاع الهولندي'),
    "Elephant Gambit": ("Gambit de l'éléphant", 'Gambito del elefante', 'مناورة الفيل'),
    "English Opening": ('Ouverture anglaise', 'Apertura inglesa', 'الافتتاح الإنجليزي'),
    "Englund Gambit": ('Gambit Englund', 'Gambito Englund', 'مناورة إنغلوند'),
    "Four Knights Game": ('Partie des quatre cavaliers', 'Partida de los cuatro caballos', 'لعبة الأحصنة الأربعة'),
    "French Defense": ('Défense française', 'Defensa francesa', 'الدفاع الفرنسي'),
    "Goldsmith Defense": ('Défense Goldsmith', 'Defensa Goldsmith', 'دفاع غولدسميث'),
    "Grob Opening": ('Ouverture Grob', 'Apertura Grob', 'افتتاح غروب'),
    "Grünfeld Defense": ('Défense Grünfeld', 'Defensa Grünfeld', 'دفاع غرونفيلد'),
    "Horwitz Defense": ('Défense Horwitz', 'Defensa Horwitz', 'دفاع هورفيتز'),
    "Hungarian Opening": ('Ouverture hongroise', 'Apertura húngara', 'الافتتاح المجري'),
    "Indian Defense": ('Défense indienne', 'Defensa india', 'الدفاع الهندي'),
    "Italian Game": ('Partie italienne', 'Apertura italiana', 'اللعبة الإيطالية'),
    "King's Gambit": ('Gambit du roi', 'Gambito de rey', 'مناورة الملك'),
    "King's Gambit Accepted": ('Gambit du roi accepté', 'Gambito de rey aceptado', 'مناورة الملك المقبولة'),
    "King's Gambit Declined": ('Gambit du roi refusé', 'Gambito de rey rehusado', 'مناورة الملك المرفوضة'),
    "King's Indian Attack": ('Attaque est-indienne', 'Ataque indio de rey', 'الهجوم الهندي الملكي'),
    "King's Indian Defense": ('Défense est-indienne', 'Defensa india de rey', 'الدفاع الهندي الملكي'),
    "King's Knight Opening": ('Ouverture du cavalier-roi', 'Apertura de caballo de rey', 'افتتاح حصان الملك'),
    "King's Pawn": ('Partie du pion-roi', 'Peón de rey', 'بيدق الملك'),
    "King's Pawn Game": ('Partie du pion-roi', 'Peón de rey', 'بيدق الملك'),
    "King's Pawn Opening": ('Partie du pion-roi', 'Peón de rey', 'بيدق الملك'),
    "Latvian Gambit": ('Gambit letton', 'Gambito letón', 'المناورة اللاتفية'),
    "Latvian Gambit Accepted": ('Gambit letton', 'Gambito letón', 'المناورة اللاتفية'),
    "London System": ('Système de Londres', 'Sistema Londres', 'نظام لندن'),
    "Modern Defense": ('Défense moderne', 'Defensa moderna', 'الدفاع الحديث'),
    "Nimzo-Indian Defense": ('Défense nimzo-indienne', 'Defensa nimzoindia', 'الدفاع النيمزو-هندي'),
    "Nimzo-Larsen Attack": ('Attaque Nimzo-Larsen', 'Ataque Nimzo-Larsen', 'هجوم نيمزو-لارسن'),
    "Nimzowitsch Defense": ('Défense Nimzowitsch', 'Defensa Nimzowitsch', 'دفاع نيمزوفيتش'),
    "Old Indian Defense": ('Vieille défense indienne', 'Defensa india antigua', 'الدفاع الهندي القديم'),
    "Owen Defense": ('Défense Owen', 'Defensa Owen', 'دفاع أوين'),
    "Petrov's Defense": ('Défense russe', 'Defensa Petrov', 'دفاع بتروف'),
    "Philidor Defense": ('Défense Philidor', 'Defensa Philidor', 'دفاع فيليدور'),
    "Pirc Defense": ('Défense Pirc', 'Defensa Pirc', 'دفاع بيرتس'),
    "Polish Opening": ('Ouverture polonaise', 'Apertura polaca', 'الافتتاح البولندي'),
    "Ponziani Opening": ('Ouverture Ponziani', 'Apertura Ponziani', 'افتتاح بونزياني'),
    "Portuguese Opening": ('Ouverture portugaise', 'Apertura portuguesa', 'الافتتاح البرتغالي'),
    "Queen's Gambit": ('Gambit dame', 'Gambito de dama', 'مناورة الوزير'),
    "Queen's Gambit Accepted": ('Gambit dame accepté', 'Gambito de dama aceptado', 'مناورة الوزير المقبولة'),
    "Queen's Gambit Declined": ('Gambit dame refusé', 'Gambito de dama rehusado', 'مناورة الوزير المرفوضة'),
    "Queen's Indian Defense": ('Défense ouest-indienne', 'Defensa india de dama', 'الدفاع الهندي الوزيري'),
    "Queen's Pawn Game": ('Partie du pion-dame', 'Peón de dama', 'بيدق الوزير'),
    "Rat Defense": ('Défense du rat', 'Defensa de la rata', 'دفاع الجرذ'),
    "Réti Opening": ('Ouverture Réti', 'Apertura Réti', 'افتتاح ريتي'),
    "Richter-Veresov Attack": ('Attaque Richter-Veresov', 'Ataque Richter-Veresov', 'هجوم ريختر-فيريسوف'),
    "Rubinstein Opening": ('Ouverture Rubinstein', 'Apertura Rubinstein', 'افتتاح روبنشتاين'),
    "Russian Game": ('Défense russe', 'Defensa Petrov', 'دفاع بتروف'),
    "Ruy Lopez": ('Partie espagnole', 'Apertura española', 'الافتتاح الإسباني'),
    "Saragossa Opening": ('Ouverture de Saragosse', 'Apertura Zaragoza', 'افتتاح سرقسطة'),
    "Scandinavian Defense": ('Défense scandinave', 'Defensa escandinava', 'الدفاع الإسكندنافي'),
    "Scotch Game": ('Partie écossaise', 'Apertura escocesa', 'اللعبة الاسكتلندية'),
    "Semi-Slav Defense": ('Défense semi-slave', 'Defensa semieslava', 'الدفاع شبه السلافي'),
    "Sicilian Defense": ('Défense sicilienne', 'Defensa siciliana', 'الدفاع الصقلي'),
    "Slav Defense": ('Défense slave', 'Defensa eslava', 'الدفاع السلافي'),
    "St. George Defense": ('Défense Saint-Georges', 'Defensa San Jorge', 'دفاع القديس جورج'),
    "Three Knights Opening": ('Partie des trois cavaliers', 'Apertura de los tres caballos', 'لعبة الأحصنة الثلاثة'),
    "Trompowsky Attack": ('Attaque Trompowsky', 'Ataque Trompowsky', 'هجوم ترومبوفسكي'),
    "Van Geet Opening": ('Ouverture Van Geet', 'Apertura Van Geet', 'افتتاح فان غيت'),
    "Vienna Game": ('Partie viennoise', 'Partida vienesa', 'اللعبة الفيينية'),
    "Bogo-Indian Defense": ('Défense bogo-indienne', 'Defensa bogoindia', 'الدفاع البوغو-هندي'),
    "Centre Game": ('Partie du centre', 'Apertura central', 'لعبة المركز'),
    "Dutch": ('Défense hollandaise', 'Defensa holandesa', 'الدفاع الهولندي'),
    "Four Knights, Scotch Variation": ('Quatre cavaliers, variante écossaise', 'Cuatro caballos, variante escocesa', 'الأحصنة الأربعة، المتغير الاسكتلندي'),
    "Giuoco Piano": ('Giuoco Piano', 'Giuoco Piano', 'جوكو بيانو'),
    "Hungarian Opening: Symmetrical Variation": ('Ouverture hongroise, variante symétrique', 'Apertura húngara, variante simétrica', 'الافتتاح المجري، المتغير المتماثل'),
    "Italian Game: Scotch Gambit, Max Lange Attack": ('Attaque Max Lange', 'Ataque Max Lange', 'هجوم ماكس لانغه'),
    "King's Indian Attack: French Variation": ('Attaque est-indienne, variante française', 'Ataque indio de rey, variante francesa', 'الهجوم الهندي الملكي، المتغير الفرنسي'),
    "King's Indian, East Indian Defense": ('Défense est-indienne', 'Defensa india de rey', 'الدفاع الهندي الملكي'),
    "Larsen's Opening": ('Ouverture Larsen', 'Apertura Larsen', 'افتتاح لارسن'),
    "Nimzovich Defense": ('Défense Nimzowitsch', 'Defensa Nimzowitsch', 'دفاع نيمزوفيتش'),
    "Nimzovich-Larsen Attack": ('Attaque Nimzowitsch-Larsen', 'Ataque Nimzowitsch-Larsen', 'هجوم نيمزوفيتش-لارسن'),
    "Old Benoni Defense": ('Vieille défense Benoni', 'Defensa Benoni antigua', 'دفاع بينوني القديم'),
    "Queen Pawn Counter Gambit": ('Contre-gambit Elephant', 'Contragambito del peón de dama', 'مناورة بيدق الوزير المضادة'),
    "Queen's Gambit Declined Slav Defense": ('Défense slave', 'Defensa eslava', 'الدفاع السلافي'),
    "Bird's Opening, From's Gambit": ('Gambit From', 'Gambito From', 'مناورة فروم'),
    "Queen's Gambit Declined, 4.Bg5": ('Gambit dame refusé, 4.Fg5', 'Gambito de dama rehusado, 4.Ag5', 'مناورة الوزير المرفوضة'),
    "Queen's Pawn": ('Partie du pion-dame', 'Peón de dama', 'بيدق الوزير'),
    "Robatsch Defense": ('Défense Robatsch', 'Defensa Robatsch', 'دفاع روباتش'),
    "Two Knights Defense": ('Défense des deux cavaliers', 'Defensa de los dos caballos', 'دفاع الحصانين'),
    "Zukertort Opening: Tennison Gambit": ('Gambit Tennison', 'Gambito Tennison', 'مناورة تينيسون'),
    "Vienna Gambit": ('Gambit viennois', 'Gambito vienés', 'المناورة الفيينية'),
    "Zukertort Opening": ('Ouverture Zukertort', 'Apertura Zukertort', 'افتتاح زوكرتورت'),
    "Blackmar-Diemer Gambit Accepted": ('Gambit Blackmar-Diemer accepté', 'Gambito Blackmar-Diemer aceptado', 'مناورة بلاكمار-ديمر'),
    "Blackmar-Diemer Gambit Declined": ('Gambit Blackmar-Diemer refusé', 'Gambito Blackmar-Diemer rehusado', 'مناورة بلاكمار-ديمر'),
    "Borg Defense": ('Défense Borg', 'Defensa Borg', 'دفاع بورغ'),
    "Evans Gambit": ('Gambit Evans', 'Gambito Evans', 'مناورة إيفانز'),
    "Benko Gambit Accepted": ('Gambit Benko accepté', 'Gambito Benko aceptado', 'مناورة بينكو'),
    "Benko Gambit Declined": ('Gambit Benko refusé', 'Gambito Benko rehusado', 'مناورة بينكو'),
    "Danish Gambit Accepted": ('Gambit danois accepté', 'Gambito danés aceptado', 'المناورة الدنماركية'),
    "Danish Gambit Declined": ('Gambit danois refusé', 'Gambito danés rehusado', 'المناورة الدنماركية'),
    "Tarrasch Defense": ('Défense Tarrasch', 'Defensa Tarrasch', 'دفاع تاراش'),
    "Tennison Gambit": ('Gambit Tennison', 'Gambito Tennison', 'مناورة تينيسون'),
    "Rapport-Jobava System": ('Système Rapport-Jobava', 'Sistema Rapport-Jobava', 'نظام رابورت-يوبافا'),
    "Mikenas Defense": ('Défense Mikenas', 'Defensa Mikenas', 'دفاع ميكيناس'),
    "Czech Defense": ('Défense tchèque', 'Defensa checa', 'الدفاع التشيكي'),
    "Barnes Defense": ('Défense Barnes', 'Defensa Barnes', 'دفاع بارنز'),
    "Duras Gambit": ('Gambit Duras', 'Gambito Duras', 'مناورة دوراس'),
}

# "Staunton Gambit" reads "gambit Staunton" in French and Spanish.
VARIATION_WORDS = {
    'fr': {'Variation': 'variante', 'Gambit': 'gambit', 'Attack': 'attaque', 'Defense': 'défense',
           'Countergambit': 'contre-gambit', 'Line': 'ligne', 'System': 'système'},
    'es': {'Variation': 'variante', 'Gambit': 'gambito', 'Attack': 'ataque', 'Defense': 'defensa',
           'Countergambit': 'contragambito', 'Line': 'línea', 'System': 'sistema'},
}
STATE_WORDS = {
    'fr': {'Accepted': 'accepté', 'Declined': 'refusé', 'Deferred': 'différé'},
    'es': {'Accepted': 'aceptado', 'Declined': 'rehusado', 'Deferred': 'diferido'},
}


def localize_variation(text, lang):
    if text in PLAIN_VARIATIONS:
        return PLAIN_VARIATIONS[text][0 if lang == 'fr' else 1]
    words = '|'.join(VARIATION_WORDS[lang])
    text = re.sub(rf"([\w'’.-]+(?: [\w'’.-]+)?) ({words})\b",
                  lambda m: f'{VARIATION_WORDS[lang][m.group(2)]} {m.group(1)}', text)
    for en, tr in STATE_WORDS[lang].items():
        text = re.sub(rf'\b{en}\b', tr, text)
    return text


def load_eco(folder):
    eco = {}
    for path in glob.glob(os.path.join(folder, '*.tsv')):
        for line in open(path, encoding='utf8').read().splitlines()[1:]:
            _, name, pgn = line.split('\t')[:3]
            eco[tuple(t for t in pgn.split() if not t.endswith('.'))] = name
    return eco


def main_variation(name):
    # lichess files these under "Indian Defense", which nobody calls them.
    budapest = re.match(r'Indian Defense: Budapest (?:Defense|Gambit)(?: Accepted| Declined)?(?:, )?(.*)', name)
    if budapest:
        name = f'Budapest Defense: {budapest.group(1)}'
    family, _, rest = re.sub(r', with .*$', '', name).partition(': ')
    parts = [p for p in rest.split(', ') if p not in EMPTY_VARIATIONS]
    first = parts[0] if parts else ''
    return f'{family}: {first}' if first else family


def is_named_trap(base):
    return base in KNOWN or base.endswith((' Trap', ' Mate'))


def longest_match(moves, eco):
    for n in range(len(moves), 0, -1):
        name = eco.get(tuple(moves[:n]))
        if name:
            return name
    return ''


def has_subsequence(moves, wanted):
    it = iter(moves)
    return all(m in it for m in wanted)


def signature(moves):
    for wanted, name in SIGNATURES:
        if moves[:len(wanted)] == list(wanted) or (wanted[0] == 'Nf3' and has_subsequence(moves, wanted)):
            return name
    return None


def proper(old):
    for p in PROPER:
        if p.lower() in old.lower():
            if 'Mate' in p or 'Gambit' in p or 'Attack' in p:
                return p
            return f'{p} Trap'
    return None


def motif(old, moves):
    last = moves[-1]
    m = re.search(r'\b([BN])x([a-h][1-8]) Sacrifice( & Mate)?', old)
    if m:
        return ('sac', m.group(1), m.group(2), bool(m.group(3)))
    for key in MOTIFS:
        if key.lower() in old.lower() and key not in ('Trap', 'Checkmate', 'Queen Trap'):
            return key
    if re.search(r'Queen Trap|Win the Queen|Wins? .*Queen', old):
        return 'Wins the Queen' if 'Win' in old else 'Queen Trap'
    if 'fork' in old.lower():
        return 'Knight Fork' if 'night' in old.lower() else 'Trap'
    if last.endswith('#'):
        piece = {'Q': 'Queen Mate', 'R': 'Rook Mate', 'B': 'Bishop Mate', 'N': 'Knight Mate'}
        return piece.get(last[0], 'Pawn Mate')
    return 'Trap'


def motif_text(key, lang):
    i = {'en': -1, 'fr': 0, 'es': 1, 'ar': 2}[lang]
    if isinstance(key, tuple):
        _, p, sq, mate = key
        piece = PIECES[p]
        text = {
            'en': f'{piece[0]} Sacrifice on {sq}',
            'fr': f'Sacrifice {piece[1]} sur {sq}',
            'es': f'Sacrificio {piece[2]} en {sq}',
            'ar': f'تضحية {piece[3]} في {sq}',
        }[lang]
        return text + {'en': ' & Mate', 'fr': ' et mat', 'es': ' y mate', 'ar': ' ثم كش مات'}[lang] if mate else text
    return key if lang == 'en' else MOTIFS[key][i]


def localize_base(base, lang):
    """The opening or trap in [lang]. Arabic keeps only the family: Latin
    surnames in the middle of an Arabic title break its reading order."""
    i = {'fr': 0, 'es': 1, 'ar': 2}[lang]
    if base in KNOWN:
        return KNOWN[base][i]
    if base.endswith(' Trap'):
        name = base[:-len(' Trap')].split(': ')[-1]
        return {'fr': f'Piège {name}', 'es': f'Trampa {name}', 'ar': f'فخ {AR_NAMES.get(name, name)}'}[lang]
    if lang == 'ar' and base in AR_GAMBITS:
        return AR_GAMBITS[base]
    family, _, rest = base.partition(': ')
    if family not in FAMILIES:
        return None if lang == 'ar' else localize_variation(base, lang)
    head = FAMILIES[family][i]
    if not rest or lang == 'ar':
        return head
    return f'{head}, {localize_variation(rest, lang)}'


def title(base, key, lang):
    b = base.replace(': ', ', ') if lang == 'en' else localize_base(base, lang)
    if is_named_trap(base):
        return b
    text = motif_text(key, lang)
    if b is None:
        return text
    if key == 'Trap' and lang == 'en':
        return f'{b} Trap'
    if lang == 'ar':
        return f'{text} — {b}'
    return f"{b}{' : ' if lang == 'fr' else ': '}{text}"


def decisive_move(moves, lang):
    ply = len(moves)
    san = moves[-1]
    if lang in SAN_PIECES:
        san = re.sub(r'^[QRBN]', lambda m: m.group().translate(SAN_PIECES[lang]), san)
        san = re.sub(r'=([QRBN])', lambda m: '=' + m.group(1).translate(SAN_PIECES[lang]), san)
    text = f"{(ply + 1) // 2}{'.' if ply % 2 else '...'}{san}"
    return f'\u2066{text}\u2069' if lang == 'ar' else text


def clean_opening(name):
    """"Philidor's defence" to "Philidor's Defense": one spelling, as printed."""
    small = {'with', 'of', 'the', 'and', 'for', 'to', 'in'}
    words = [w if w in small and i else w[:1].upper() + w[1:] for i, w in enumerate(name.split(' '))]
    return ' '.join(words).replace('Defence', 'Defense').replace('Petroff', 'Petrov')


def family_of(name):
    candidates = [name, name.replace("'s ", ' '), name.replace(' Opening', ' Game'),
                  name.replace(' Game', ' Opening'), name.replace('Gruenfeld', 'Grünfeld'),
                  name.replace('Grunfeld', 'Grünfeld'), name.replace('Reti', 'Réti')]
    return next((FAMILIES[c] for c in candidates if c in FAMILIES), None)


def write_opening_names(parts):
    names = sorted({re.search(r'opening: ([\'"])(.*?)\1,', p).group(2).replace(r"\'", "'")
                    for p in parts if p.startswith('ChessTrap(')})
    lines = ['// GENERATED FILE - DO NOT EDIT', '// By scripts/apply_trap_names.py', '',
             '/// Opening name to its French, Spanish and Arabic names.',
             'const Map<String, List<String>> openingNames = <String, List<String>>{']
    missing = []
    for name in names:
        row = family_of(name)
        if row is None:
            missing.append(name)
            continue
        lines.append(f"  {json.dumps(name, ensure_ascii=False)}: <String>{json.dumps(list(row), ensure_ascii=False)},")
    lines.append('};')
    open('lib/generated/chess/opening_names.dart', 'w', encoding='utf8', newline='').write('\n'.join(lines) + '\n')
    print('openings without translation:', missing)


def write_name_index(parts):
    """Same output as scripts/generate_chess_tries.dart, for the names only."""
    index = {}
    for part in parts:
        if not part.startswith('ChessTrap('):
            continue
        trap_id = int(re.search(r'id: (\d+),', part).group(1))
        keys = []
        for field in ('opening', 'trapName', 'trapNameFr', 'trapNameEs', 'trapNameAr'):
            value = re.search(field + r""": (['"])(.*?)\1,\n""", part).group(2)
            key = value.replace(r'\"', '"').replace(r"\'", "'").lower()
            if key not in keys:
                keys.append(key)
        for key in keys:
            index.setdefault(key, []).append(trap_id)
    lines = ['// GENERATED FILE - DO NOT EDIT', '// Flat name index for openings/trap names', '',
             'const Map<String, List<int>> nameIndex = <String, List<int>>{']
    for key, ids in index.items():
        escaped = json.dumps(key, ensure_ascii=False).replace('$', r'\$')
        lines.append(f'  {escaped}: <int>{ids},')
    lines.append('};')
    open('lib/generated/chess/prebuilt_name_index.dart', 'w', encoding='utf8', newline='').write('\n'.join(lines) + '\n')


def main():
    eco = load_eco(sys.argv[1])
    src = open(FILE, encoding='utf8').read()
    pattern = re.compile(r'(ChessTrap\(\n.*?\n\s*\),\n)', re.S)
    parts = pattern.split(src)
    rows = []
    for i, part in enumerate(parts):
        if not part.startswith('ChessTrap('):
            continue
        old = re.search(r'trapName: ([\'"])(.*?)\1,\n', part).group(2)
        moves = json.loads(re.search(r'moves: (\[.*?\]),\n', part, re.S).group(1).replace("'", '"').rstrip(',]').rstrip() + ']')
        base = signature(moves) or proper(old) or main_variation(longest_match(moves, eco)) or re.sub(r':.*', '', old)
        rows.append([i, old, moves, base, motif(old, moves)])

    # The same base and motif twice: name the decisive move, which is real
    # information, instead of numbering them.
    groups = collections.defaultdict(list)
    for row in rows:
        groups[(row[3], str(row[4]))].append(row)
    seen = {}
    seen_ar = collections.Counter()
    ar_titles = collections.Counter(title(r[3], r[4], 'ar') for r in rows)
    stats = collections.Counter()
    for row in rows:
        i, old, moves, base, key = row
        names = {l: title(base, key, l) for l in ('en', 'fr', 'es', 'ar')}
        if not is_named_trap(base) and (len(groups[(base, str(key))]) > 1 or names['en'] in seen):
            names = {l: f'{n} ({decisive_move(moves, l)})' for l, n in names.items()}
        n = 2
        unique = names['en']
        while unique in seen:
            unique = f"{names['en']} {['', '', 'II', 'III', 'IV', 'V', 'VI'][n] if n < 7 else n}"
            n += 1
        if unique != names['en']:
            suffix = unique[len(names['en']):]
            names = {l: v + suffix for l, v in names.items()}
        seen[names['en']] = True
        if ar_titles[title(base, key, 'ar')] > 1 and not is_named_trap(base) and '(' not in names['ar']:
            names['ar'] = f"{names['ar']} ({decisive_move(moves, 'ar')})"
        for lang in ('fr', 'es', 'ar'):
            seen_ar[names[lang]] += 1
            if seen_ar[names[lang]] > 1:
                names[lang] = f'{names[lang]} {seen_ar[names[lang]]}'
        stats['named' if is_named_trap(base) else 'variation'] += 1
        part = re.sub(r"""(opening: )(['"])(.*?)\2,""", lambda m: f'{m.group(1)}{json.dumps(clean_opening(m.group(3).replace(chr(92) + chr(39), chr(39))), ensure_ascii=False)},', parts[i], count=1)
        for field, lang in (('trapName', 'en'), ('trapNameFr', 'fr'), ('trapNameEs', 'es'), ('trapNameAr', 'ar')):
            part = re.sub(rf'{field}: ([\'"]).*?\1,\n', lambda _: f'{field}: {json.dumps(names[lang], ensure_ascii=False)},\n', part, count=1)
        parts[i] = part
        row.append(names)
    open(FILE, 'w', encoding='utf8', newline='').write(''.join(parts))
    write_name_index(parts)
    write_opening_names(parts)
    # Written as escapes: the analyzer rejects raw bidi controls in source.
    for path in (FILE, 'lib/generated/chess/prebuilt_name_index.dart'):
        text = open(path, encoding='utf8').read().replace(chr(0x2066), chr(92) + 'u2066').replace(chr(0x2069), chr(92) + 'u2069')
        open(path, 'w', encoding='utf8', newline='').write(text)
    eco_file = 'lib/data/traps/openings.dart'
    eco_src = open(eco_file, encoding='utf8').read()
    eco_src = re.sub(r"""(\bname: )(['"])(.*?)\2,""", lambda m: f'{m.group(1)}{json.dumps(clean_opening(m.group(3)), ensure_ascii=False)},', eco_src)
    open(eco_file, 'w', encoding='utf8', newline='').write(eco_src)
    print(stats, 'unique', len(seen), 'of', len(rows))
    missing = collections.Counter(r[3].split(': ')[0] for r in rows if r[3].split(': ')[0] not in FAMILIES and r[3] not in KNOWN)
    print('no family:', missing.most_common(60))
    json.dump([r[1:2] + [r[5]] for r in rows], open(sys.argv[2], 'w', encoding='utf8'), ensure_ascii=False, indent=0)


main()
