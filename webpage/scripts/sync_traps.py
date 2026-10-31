"""Copies the trap library from the app into the site.

The app's generated Dart file is the source of truth, so names and openings
fixed there reach the site without being edited twice. Run from webpage/:

    python scripts/sync_traps.py
"""
import json
import re

SOURCE = "../lib/generated/chess/base_chess_traps.dart"
TARGET = "src/data/traps.json"

STRING_FIELDS = [
    "cleanMoves",
    "metadata",
    "opening",
    "openingId",
    "trapName",
    "trapNameFr",
    "trapNameEs",
    "trapNameAr",
    "commentedMoves",
    "fen",
]


def field(entry: str, name: str) -> str:
    match = re.search(rf'^\s*{name}:\s*"((?:[^"\\]|\\.)*)",?\s*$', entry, re.M)
    if not match:
        raise ValueError(f"no {name} in: {entry[:80]}")
    return json.loads(f'"{match.group(1)}"'.replace("\\$", "$"))


def main() -> None:
    source = open(SOURCE, encoding="utf8").read()
    traps = []
    for entry in source.split("ChessTrap(")[1:]:
        trap = {"id": int(re.search(r"id:\s*(\d+)", entry).group(1))}
        trap.update({name: field(entry, name) for name in STRING_FIELDS})
        moves = re.search(r"moves:\s*\[(.*?)\]", entry, re.S).group(1)
        trap["moves"] = re.findall(r'"([^"]+)"', moves)
        trap["targetSide"] = re.search(r"targetSide:\s*Side\.(\w+)", entry).group(1)
        traps.append(trap)

    with open(TARGET, "w", encoding="utf8", newline="\n") as out:
        json.dump(traps, out, ensure_ascii=False)
        out.write("\n")
    print(f"{len(traps)} traps written to {TARGET}")


if __name__ == "__main__":
    main()
