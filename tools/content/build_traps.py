import json, io, os, re, sys, collections
import chess
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from motifs import make_title, analyse, tidy_opening

sys.stdout.reconfigure(encoding="utf-8")
ROOT = r"C:\Users\User\coding\products\chess-traps"
OUT = os.path.join(ROOT, "webpage/src/data")

app = json.load(io.open(os.path.join(ROOT, "webpage/src/data/traps.json"), encoding="utf-8"))
raw = json.load(io.open(os.path.join(ROOT, "webpage/chess_traps/data/master_traps.json"),
                        encoding="utf-8", errors="replace"))


def norm_key(m):
    s = re.sub(r"\[[^\]]*\]", " ", m or "")
    s = re.sub(r"\([^)]*\)", " ", s)
    s = s.replace("…", " ").replace("...", " ")
    s = re.sub(r"\d+\s*\.+", " ", s)
    s = re.sub(r"[?!]+", "", s)
    s = s.replace("mate", "#").replace("0-0-0", "O-O-O").replace("0-0", "O-O")
    toks = re.findall(r"[KQRBNO][\w\-+#=]*|[a-h][\w\-+#=]*", s)
    return " ".join(t.replace("#", "").replace("+", "") for t in toks)


# The browse-by-opening UI groups traps by matching trap.opening against the
# names in lib/data/traps/openings.dart *exactly*. Re-casing an opening name
# silently empties those groups, so any name that matches an ECO opening
# case-insensitively is snapped back to the canonical ECO spelling.
_eco_src = io.open(os.path.join(ROOT, "lib/data/traps/openings.dart"), encoding="utf-8").read()
ECO_NAMES = set(m.group(1) for m in re.finditer(r'name:\s*"((?:[^"\\]|\\.)*)"', _eco_src))
ECO_CI = {n.lower(): n for n in ECO_NAMES}


def canonical_opening(name):
    n = (name or "").strip()
    if not n:
        return ""
    exact = ECO_CI.get(n.lower())
    if exact:
        return exact
    t = tidy_opening(n)
    return ECO_CI.get(t.lower(), t)


def clean_text(s):
    if not s:
        return ""
    s = (s.replace("\u2019", "'").replace("\u2018", "'")
           .replace("\u201c", '"').replace("\u201d", '"')
           .replace("\ufffd", "'").replace("\u2026", "..."))
    return re.sub(r"\s+", " ", s).strip()


# A handful of titles were authored with decorative emoji ("\ud83d\udcd5 London Defense
# [Bb4] - Theory \ud83d\udca1"), which look out of place next to every other trap and add
# noise to search results and page titles.
EMOJI_RE = re.compile(
    "[" "\U0001F300-\U0001FAFF" "\U00002600-\U000027BF" "\U0001F000-\U0001F0FF"
    "\U00002190-\U000021FF" "\U0000FE0F" "]+", flags=re.UNICODE)


def strip_decoration(s):
    s = EMOJI_RE.sub(" ", s or "")
    s = re.sub(r"\s*-\s*Theory\s*$", "", s, flags=re.I)
    return re.sub(r"\s+", " ", s).strip(" -")


def parse_moves(clean):
    key = norm_key(clean)
    if not key:
        return [], "", False
    b = chess.Board()
    sans = []
    for tok in key.split():
        try:
            mv = b.parse_san(tok)
        except Exception:
            return [], "", False
        sans.append(b.san(mv))
        b.push(mv)
    return sans, b.fen(), True


GOOD = ("trap", "mate", "gambit", "attack", "sacrifice", "countergambit", "shilling",
        "fried", "liver", "fishing", "pole", "smothered", "legal", "l\u00e9gal",
        "noah", "ark", "elephant", "blackburne", "lasker", "englund", "halosar",
        "traxler", "monkey", "tennison", "magnus", "lolli", "cambridge", "milner",
        "poisoned", "fork", "wins", "win",
        # words the generated motif titles themselves use, so a title we just
        # produced is never mistaken for junk on a later pass
        "queen", "rook", "bishop", "knight", "pawn", "piece", "exchange",
        "promotion", "opening", "defence", "defense", "game", "miniature",
        "back-rank", "pin", "skewer", "discovered", "counterattack")


PLAYERS_RE = re.compile(r"\bvs?\b\.?|\bversus\b", re.I)
# Whole-word match only. Substring matching silently rescued junk titles:
# "ark" (Noah's Ark) occurs inside "Parkov", "Denmark" and "Arkansas".
GOOD_RE = re.compile(r"\b(" + "|".join(w.strip() for w in GOOD) + r")\b", re.I)


def is_bad_name(name, opening):
    n = clean_text(name)
    if not n:
        return True
    # These are unconditionally bad, even when a real chess word appears in a
    # player's surname ("De Legal vs St. Brie", "Wall, Bill vs SmartAttack").
    if PLAYERS_RE.search(n):
        return True
    if "_" in n:                      # import damage, e.g. "Woge_Nielsem"
        return True
    if GOOD_RE.search(n):
        return False
    # Nothing chess-related left in the title, so it cannot be describing a
    # trap. This is what catches the venues the importer wrote as names —
    # "Mountain View, CA", "Wijk aan Zee", "Denmark" — including the ones with
    # commas or lower-case particles that a proper-noun pattern misses.
    return True


# Two traps shipped with corrupt move lists (swapped pairs / missing moves) so
# their SAN could never be replayed — almost certainly the source of the
# PlayException crashes seen in Crashlytics. They are repaired in place rather
# than removed: the app looks traps up by *index*, and chess_groups.dart plus
# every saved favourite/learned id and every /trap/:id deep link depend on the
# existing positions staying put.
REPAIRS = {
    824: {
        "trapName": "Italian Game: Max Lange Attack, Nxf7 Sacrifice",
        "opening": "Italian Game: Scotch Gambit, Max Lange Attack",
        "cleanMoves": ("1.e4 e5 2.Nf3 Nc6 3.Bc4 Bc5 4.O-O Nf6 5.d4 exd4 6.e5 d5 "
                       "7.exf6 dxc4 8.Re1+ Be6 9.Ng5 Qd5 10.Nc3 Qf5 11.Nce4 Bf8 "
                       "12.Nxf7 Kxf7 13.Ng5+ Kg8 14.g4 Qxf6 15.Rxe6"),
    },
    849: {
        "trapName": "Tennison Gambit: ICBM Trap",
        "opening": "Zukertort Opening: Tennison Gambit",
        "cleanMoves": ("1.Nf3 d5 2.e4 dxe4 3.Ng5 Nf6 4.d3 exd3 5.Bxd3 h6 "
                       "6.Nxf7 Kxf7 7.Bg6+ Kxg6 8.Qxd8"),
    },
}

raw_by_key = {}
for r in raw:
    k = norm_key(r.get("clean_moves", ""))
    if k and k not in raw_by_key:
        raw_by_key[k] = r

used = set()
for t in app:                     # protect the curated names
    if not is_bad_name(t["trapName"], t["opening"]):
        used.add(clean_text(t["trapName"]))

renamed = annotated = meta_fixed = repaired = 0
out = []
for t in app:
    t = dict(t)
    if t["id"] in REPAIRS:
        t.update(REPAIRS[t["id"]])
        t["commentedMoves"] = t["cleanMoves"]
        repaired += 1
    t["trapName"] = strip_decoration(clean_text(t["trapName"]))
    t["opening"] = canonical_opening(t["opening"])
    key = norm_key(t["cleanMoves"])

    sans, fen, ok = parse_moves(t["cleanMoves"])
    if not ok or not sans:
        # Must never happen after REPAIRS; keep the entry so indices are stable.
        print(f"  !! still illegal: #{t['id']} {t['trapName']}")
        out.append(t)
        continue
    t["moves"], t["fen"] = sans, fen

    src = raw_by_key.get(key)
    if src:
        cm = clean_text(src.get("commented_moves", ""))
        if cm and norm_key(cm) == key and cm != clean_text(t["cleanMoves"]):
            t["commentedMoves"] = cm
            annotated += 1
        meta = clean_text(src.get("metadata", ""))
        if meta and re.search(r"\b(1[6-9]|20)\d{2}\b", meta):
            t["metadata"] = meta
            meta_fixed += 1

    if is_bad_name(t["trapName"], t["opening"]):
        # Don't lose the players: if the old title was "A vs B" and we have no
        # attribution yet, keep it as the trap's metadata line.
        if PLAYERS_RE.search(t["trapName"]) and not re.search(
                r"\b(1[6-9]|20)\d{2}\b", t.get("metadata", "") or ""):
            players = PLAYERS_RE.sub("-", t["trapName"]).replace("_", " ")
            t["metadata"] = re.sub(r"\s+", " ", players).strip(" -")
        title, _ = make_title(t["opening"], sans, t.get("metadata", ""), used)
        if title:
            t["trapName"] = title
            renamed += 1
    else:
        used.add(t["trapName"])

    d = analyse(sans)
    if d["winner"]:
        t["targetSide"] = d["winner"].lower()
    out.append(t)

print(f"existing traps              : {len(app)}")
print(f"  repaired corrupt lines    : {repaired}")
print(f"  retitled (venue/generic)  : {renamed}")
print(f"  annotations recovered     : {annotated}")
print(f"  game attribution restored : {meta_fixed}")

existing = {norm_key(t["cleanMoves"]) for t in out}
next_id = 0
added = skipped = 0
for k, r in raw_by_key.items():
    if k in existing:
        continue
    sans, fen, ok = parse_moves(r.get("clean_moves", ""))
    if not ok or not (6 <= len(sans) <= 40):
        skipped += 1
        continue
    opening = canonical_opening(clean_text(r.get("opening", "")))
    meta = clean_text(r.get("metadata", ""))
    title, d = make_title(opening, sans, meta, used)
    if not title:
        skipped += 1
        continue
    cm = clean_text(r.get("commented_moves", ""))
    out.append({
        "id": 0,
        "opening": opening,
        "openingId": re.sub(r"[^a-z0-9]+", "_", opening.lower()).strip("_"),
        "trapName": title,
        "trapNameFr": title, "trapNameEs": title, "trapNameAr": title,
        "cleanMoves": clean_text(r.get("clean_moves", "")),
        "commentedMoves": cm if (cm and norm_key(cm) == k) else clean_text(r.get("clean_moves", "")),
        "metadata": meta,
        "fen": fen,
        "moves": sans,
        "targetSide": (d["winner"] or "White").lower(),
    })
    existing.add(k)
    added += 1

# Final uniqueness pass. The original library already shipped 66 repeated
# titles (e.g. several traps all called the same thing), which is confusing in
# a list and terrible for SEO — every page needs a distinct <title>.
seen = {}
for t in out:
    base = t["trapName"]
    if base not in seen:
        seen[base] = 1
        continue
    m = re.match(r"^\s*([A-Za-z\.\-' ]+?)\s*[-–]\s*([A-Za-z\.\-' ]+?)\s*,",
                 (t.get("metadata") or "").strip())
    cand = f"{base} ({m.group(1).strip()}–{m.group(2).strip()})" if m else base
    if cand in seen:
        seen[base] += 1
        cand = f"{base} #{seen[base]}"
        while cand in seen:
            seen[base] += 1
            cand = f"{base} #{seen[base]}"
    seen[cand] = 1
    t["trapName"] = cand

# Index stability is a hard requirement: the app resolves traps as
# chessTraps[index], chess_groups.dart stores indices, and saved
# favourites/learned ids and /trap/:id deep links are all positional. Every
# original trap must therefore keep the exact slot it already had.
orig_ids = [t["id"] for t in app]
for i, t in enumerate(out):
    if i < len(orig_ids):
        assert t["id"] == orig_ids[i], f"index drift at {i}: {t['id']} != {orig_ids[i]}"
    t["id"] = i
assert [t["id"] for t in out[:len(app)]] == orig_ids, "original ids moved!"

print(f"  NEW traps added           : {added}  (skipped {skipped})")
print(f"TOTAL NOW                   : {len(out)}")

names = collections.Counter(t["trapName"] for t in out)
dupes = [n for n, c in names.items() if c > 1]
illegal = [t for t in out if not parse_moves(t["cleanMoves"])[2]]
venue = [t for t in out if is_bad_name(t["trapName"], t["opening"])]
withc = [t for t in out if t["commentedMoves"].strip() != t["cleanMoves"].strip()]
print(f"\nintegrity: illegal lines      = {len(illegal)}")
print(f"integrity: duplicate titles   = {len(dupes)}")
print(f"integrity: venue-named left   = {len(venue)}")
print(f"integrity: with commentary    = {len(withc)}")

json.dump(out, io.open(os.path.join(OUT, "traps.json"), "w", encoding="utf-8"), ensure_ascii=False)
print(f"\nwrote traps.json ({len(out)} traps)")

print("\n--- sample of the new titles ---")
for t in out:
    if ":" in t["trapName"]:
        print(f"  {t['trapName']}")
        if sum(1 for x in out if ':' in x['trapName'] and out.index(x) <= out.index(t)) >= 14:
            break
