import json, io, os, sys, re, collections
import chess
sys.stdout.reconfigure(encoding="utf-8")
ROOT = r"C:\Users\User\coding\products\chess-traps"

old = json.load(io.open(os.path.join(ROOT, "webpage/src/data/traps.json.bak"), encoding="utf-8"))
new = json.load(io.open(os.path.join(ROOT, "webpage/src/data/traps.json"), encoding="utf-8"))


def norm(m):
    s = re.sub(r"\[[^\]]*\]", " ", m or "")
    s = re.sub(r"\([^)]*\)", " ", s)
    s = s.replace("…", " ").replace("...", " ")
    s = re.sub(r"\d+\s*\.+", " ", s)
    s = re.sub(r"[?!]+", "", s)
    s = s.replace("mate", "#").replace("0-0-0", "O-O-O").replace("0-0", "O-O")
    return " ".join(t.replace("#", "").replace("+", "")
                    for t in re.findall(r"[KQRBNO][\w\-+#=]*|[a-h][\w\-+#=]*", s))


REPAIRED = {824, 849}
print("=== INDEX STABILITY (saved favourites / learned ids / deep links) ===")
drift = []
for i, o in enumerate(old):
    n = new[i]
    if n["id"] != o["id"]:
        drift.append((i, "id"))
    elif i not in REPAIRED and norm(n["cleanMoves"]) != norm(o["cleanMoves"]):
        drift.append((i, "moves"))
print(f"  original traps            : {len(old)}")
print(f"  positions with drift      : {len(drift)}   (expected 0)")
print(f"  intentionally repaired    : {sorted(REPAIRED)}")

print("\n=== LEGALITY (every shipped line replays cleanly) ===")
bad = []
for t in new:
    b = chess.Board()
    try:
        for san in t["moves"]:
            b.push(b.parse_san(san))
        if b.fen() != t["fen"]:
            bad.append((t["id"], "fen mismatch"))
    except Exception:
        bad.append((t["id"], "illegal"))
print(f"  traps                     : {len(new)}")
print(f"  illegal / fen mismatch    : {len(bad)}   (expected 0)")
for x in bad[:5]:
    print("   ", x)

print("\n=== CONTENT QUALITY ===")
names = collections.Counter(t["trapName"] for t in new)
print(f"  duplicate titles          : {len([n for n,c in names.items() if c>1])}")
print(f"  with teaching commentary  : {len([t for t in new if t['commentedMoves'].strip()!=t['cleanMoves'].strip()])}")
print(f"  with game attribution     : {len([t for t in new if re.search(r'\\b(1[6-9]|20)\\d{2}\\b', t.get('metadata',''))])}")
venue = [t for t in new if re.fullmatch(r"[A-Z][a-zA-Z\.\-']*(?: [A-Z][a-zA-Z\.\-']*){0,3}", t["trapName"])
         and not any(w in t["trapName"].lower() for w in ("trap","mate","gambit","attack","sacrifice","fork","wins"))]
print(f"  venue-style titles left   : {len(venue)}")
print(f"  new traps (id >= 871)     : {len([t for t in new if t['id']>=871])}")

print("\n=== SAMPLE: repaired ===")
for i in sorted(REPAIRED):
    print(f"  #{i}: {new[i]['trapName']}")
    print(f"        {new[i]['cleanMoves'][:80]}")

print("\n=== SAMPLE: newly added traps ===")
for t in new[871:876]:
    print(f"  #{t['id']}: {t['trapName']}")
    print(f"        {t['cleanMoves'][:78]}")

print("\n=== SAMPLE: recovered teaching commentary ===")
shown = 0
for t in new:
    if t["commentedMoves"].strip() != t["cleanMoves"].strip() and "[" in t["commentedMoves"]:
        print(f"  #{t['id']} {t['trapName']}")
        print(f"     {t['commentedMoves'][:150]}")
        shown += 1
        if shown >= 3:
            break
