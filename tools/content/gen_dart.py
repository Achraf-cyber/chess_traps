import json, io, os, sys
sys.stdout.reconfigure(encoding="utf-8")

ROOT = r"C:\Users\User\coding\products\chess-traps"
traps = json.load(io.open(os.path.join(ROOT, "webpage/src/data/traps.json"), encoding="utf-8"))
DEST = os.path.join(ROOT, "lib/generated/chess/base_chess_traps.dart")


def d(s):
    """Escape a Python string for a Dart double-quoted literal."""
    if s is None:
        s = ""
    return (s.replace("\\", "\\\\")
             .replace('"', '\\"')
             .replace("$", "\\$")          # Dart interpolates $
             .replace("\r", " ")
             .replace("\n", "\\n"))


parts = [
    "// GENERATED FILE DO NOT EDIT\n",
    "// ignore_for_file: prefer_single_quotes\n",
    "import 'package:chess_traps/data/traps/chess_trap.dart';\n",
    "import 'package:dartchess/dartchess.dart';\n\n",
    "const List<ChessTrap> chessTraps = [\n",
]

for t in traps:
    moves = ", ".join('"%s"' % d(m) for m in t["moves"])
    side = "Side.white" if t.get("targetSide", "white") == "white" else "Side.black"
    parts.append(
        "  ChessTrap(\n"
        f"    id: {t['id']},\n"
        f"    cleanMoves: \"{d(t['cleanMoves'])}\",\n"
        f"    metadata: \"{d(t.get('metadata', ''))}\",\n"
        f"    opening: \"{d(t['opening'])}\",\n"
        f"    openingId: \"{d(t['openingId'])}\",\n"
        f"    trapName: \"{d(t['trapName'])}\",\n"
        f"    trapNameFr: \"{d(t['trapNameFr'])}\",\n"
        f"    trapNameEs: \"{d(t['trapNameEs'])}\",\n"
        f"    trapNameAr: \"{d(t['trapNameAr'])}\",\n"
        f"    commentedMoves: \"{d(t['commentedMoves'])}\",\n"
        f"    moves: [{moves}],\n"
        f"    fen: \"{d(t['fen'])}\",\n"
        f"    targetSide: {side},\n"
        "  ),\n\n"
    )

parts.append("];\n")
io.open(DEST, "w", encoding="utf-8", newline="\n").write("".join(parts))
print(f"wrote {DEST}")
print(f"traps: {len(traps)}  bytes: {os.path.getsize(DEST):,}")
