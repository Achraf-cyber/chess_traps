"""Checks the guides in articles.py and writes src/data/articles.json.

Plays every line with python-chess, so an illegal move or a false + or # stops
the build, and resolves each board block to the FEN the page draws. Run from
webpage/:

    pip install chess
    python scripts/build_articles.py
    python scripts/build_articles.py --engine path/to/stockfish
"""
import json
import re
import sys

import chess
import chess.engine

from articles import ARTICLES, PUBLISHED

TARGET = "src/data/articles.json"
TRAPS = "src/data/traps.json"

# A whole game line quoted in prose, from move one.
SAN = r"(?:O-O(?:-O)?|[KQRBN]?[a-h]?[1-8]?x?[a-h][1-8](?:=[QRBN])?)[+#]?[!?]*"
PROSE_LINE = re.compile(rf"1\.{SAN}(?:\s+(?:\d+\.+)?{SAN})*")


def play(line: str) -> tuple[chess.Board, list[str]]:
    """Plays [line] from the start. The notation has to be exact, marks included."""
    board = chess.Board()
    played = []
    tokens = re.sub(r"\d+\.+", " ", line).replace("?", "").replace("!", "").split()
    for san in tokens:
        move = board.parse_san(san)
        board.push(move)
        # parse_san ignores check marks, so they get compared here.
        mark = "#" if board.is_checkmate() else "+" if board.is_check() else ""
        if not san.endswith(mark) or (not mark and san[-1] in "+#"):
            raise ValueError(f"wrong mark on {san} in {line}: expected '{mark}'")
        played.append(san)
    return board, played


def blocks_text(article: dict):
    yield article["intro"]
    for block in article["blocks"]:
        if block[0] in ("p", "h2"):
            yield block[1]
        elif block[0] == "ul":
            yield from block[1]
    for question, answer in article["faq"]:
        yield question
        yield answer


def check_links(article: dict, slugs: set[str], trap_count: int) -> None:
    for text in blocks_text(article):
        for path in re.findall(r"\]\((/[^)]+)\)", text):
            if path.startswith("/learn/"):
                assert path[len("/learn/"):] in slugs, f"dead link {path}"
            elif path.startswith("/trap/"):
                assert int(path[len("/trap/"):]) < trap_count, f"dead link {path}"
            else:
                assert path == "/traps", f"unknown link {path}"


def resolve(article: dict) -> dict:
    blocks = []
    for block in article["blocks"]:
        if block[0] == "board":
            _, moves, caption, orientation = block
            board, played = play(moves)
            blocks.append({
                "type": "board",
                "fen": board.fen(),
                "line": moves,
                "lastMove": board.peek().uci(),
                "caption": caption,
                "orientation": orientation,
            })
        elif block[0] == "ul":
            blocks.append({"type": "ul", "items": block[1]})
        else:
            blocks.append({"type": block[0], "text": block[1]})
    return {
        **{k: article[k] for k in ("slug", "trapId", "title", "headline", "description", "intro", "orientation")},
        "published": PUBLISHED,
        "blocks": blocks,
        "faq": [{"q": q, "a": a} for q, a in article["faq"]],
    }


def check_engine(path: str) -> int:
    failures = 0
    with chess.engine.SimpleEngine.popen_uci(path) as engine:
        for article in ARTICLES:
            for line, side, minimum in article["engine"]:
                board, _ = play(line)
                info = engine.analyse(board, chess.engine.Limit(depth=24))
                score = info["score"].pov(chess.WHITE if side == "white" else chess.BLACK).score(mate_score=10000)
                ok = score >= minimum
                failures += not ok
                print(f"{'ok ' if ok else 'BAD'} {article['slug']}: {side} {score:+} (want >= {minimum}) {line[-40:]}")
    return failures


def main() -> None:
    slugs = {a["slug"] for a in ARTICLES}
    trap_count = len(json.load(open(TRAPS, encoding="utf8")))
    lines = 0
    for article in ARTICLES:
        check_links(article, slugs, trap_count)
        for line in article["verify"]:
            play(line)
            lines += 1
        for text in blocks_text(article):
            for line in PROSE_LINE.findall(text):
                play(line.rstrip(".,"))
                lines += 1

    resolved = [resolve(a) for a in ARTICLES]
    lines += sum(1 for a in resolved for b in a["blocks"] if b["type"] == "board")
    with open(TARGET, "w", encoding="utf8", newline="\n") as out:
        json.dump(resolved, out, ensure_ascii=False, indent=2)
        out.write("\n")
    words = sum(len(t.split()) for a in ARTICLES for t in blocks_text(a))
    print(f"{len(resolved)} articles, {lines} lines checked, {words} words")

    if len(sys.argv) == 3 and sys.argv[1] == "--engine":
        failures = check_engine(sys.argv[2])
        print(f"{failures} engine claims failed")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
