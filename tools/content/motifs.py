"""Motif detection + title generation, shared by the content pipeline."""
import re
import chess

VALUE = {chess.PAWN: 1, chess.KNIGHT: 3, chess.BISHOP: 3, chess.ROOK: 5, chess.QUEEN: 9}
PIECE_NAME = {chess.QUEEN: "Queen", chess.ROOK: "Rook", chess.BISHOP: "Bishop",
              chess.KNIGHT: "Knight", chess.PAWN: "Pawn"}
PIECE_LETTER = {chess.QUEEN: "Q", chess.ROOK: "R", chess.BISHOP: "B",
                chess.KNIGHT: "N", chess.PAWN: ""}


def material(board, color):
    return sum(VALUE[p] * len(board.pieces(p, color)) for p in VALUE)


def analyse(sans):
    """Replay the line and record what tactically defines it."""
    b = chess.Board()
    d = {
        "mate": False, "mate_piece": None, "smothered": False, "back_rank": False,
        "sac": None,            # (letter, square) e.g. ("B","f7")
        "queen_won": None,      # side that LOST the queen
        "promotion": False, "fork": None, "plies": len(sans),
        "swing": 0, "winner": None, "legal": True,
    }
    for san in sans:
        try:
            mv = b.parse_san(san)
        except Exception:
            d["legal"] = False
            return d
        mover = b.piece_at(mv.from_square)
        captured = b.piece_at(mv.to_square)
        if b.is_en_passant(mv):
            captured = chess.Piece(chess.PAWN, not mover.color)

        # a minor piece taking a pawn on a king-side weak square, where the
        # capture can be answered — the classic opening sacrifice
        if (mover and captured and mover.piece_type in (chess.BISHOP, chess.KNIGHT)
                and captured.piece_type == chess.PAWN):
            sq = chess.square_name(mv.to_square)
            if sq in ("f7", "f2", "h7", "h2", "g7", "g2"):
                if VALUE[mover.piece_type] > VALUE[captured.piece_type]:
                    d["sac"] = (PIECE_LETTER[mover.piece_type], sq)

        if captured and captured.piece_type == chess.QUEEN:
            d["queen_won"] = "Black" if captured.color == chess.BLACK else "White"
        if mv.promotion:
            d["promotion"] = True

        b.push(mv)

        if b.is_checkmate():
            d["mate"] = True
            d["mate_piece"] = PIECE_NAME.get(mover.piece_type) if mover else None
            d["winner"] = "White" if not b.turn else "Black"
            k = b.king(b.turn)
            if k is not None and mover and mover.piece_type == chess.KNIGHT:
                d["smothered"] = all(
                    (b.piece_at(s) is not None and b.piece_at(s).color == b.turn)
                    for s in chess.SquareSet(chess.BB_KING_ATTACKS[k]))
            if k is not None and chess.square_rank(k) in (0, 7) and mover \
               and mover.piece_type in (chess.ROOK, chess.QUEEN):
                d["back_rank"] = True
            break

        # knight fork on two valuable pieces
        if mover and mover.piece_type == chess.KNIGHT:
            tgts = [b.piece_at(s) for s in b.attacks(mv.to_square)]
            big = [p for p in tgts if p and p.color != mover.color
                   and p.piece_type in (chess.KING, chess.QUEEN, chess.ROOK)]
            if len(big) >= 2:
                d["fork"] = "Knight"

    w, bl = material(b, chess.WHITE), material(b, chess.BLACK)
    d["swing"] = w - bl
    if not d["winner"]:
        d["winner"] = "White" if d["swing"] > 0 else ("Black" if d["swing"] < 0 else None)
    return d


def tidy_opening(op: str) -> str:
    op = re.sub(r"\s*\([^)]*\)", "", op or "").strip().rstrip(".")
    op = re.sub(r"\s+", " ", op)
    if not op:
        return ""
    # Title-case but keep small words and existing capitals sensible
    small = {"of", "the", "de", "van", "von", "and"}
    parts = []
    for i, w in enumerate(op.split()):
        parts.append(w if (w.isupper() and len(w) <= 4) else
                     (w.lower() if (i and w.lower() in small) else w[:1].upper() + w[1:]))
    op = " ".join(parts)
    op = op.replace("Defence", "Defence").replace("Defense", "Defence")
    return op


def motif_for(d):
    """A short, human phrase for what makes this trap tick."""
    if d["smothered"]:
        return "Smothered Mate"
    if d["back_rank"]:
        return "Back-Rank Mate"
    if d["mate"] and d["sac"]:
        letter, sq = d["sac"]
        return f"{letter}x{sq} Sacrifice & Mate"
    if d["mate"]:
        n = (d["plies"] + 1) // 2
        if n <= 6:
            return f"Mate in {n}"
        return f"{d['mate_piece'] or 'Mating'} Mate"
    if d["sac"]:
        letter, sq = d["sac"]
        return f"{letter}x{sq} Sacrifice"
    if d["queen_won"]:
        return f"{d['queen_won']} Queen Trap"
    if d["fork"]:
        return "Knight Fork"
    if d["promotion"]:
        return "Promotion Trap"
    a = abs(d["swing"])
    if a >= 9:
        return "Wins the Queen"
    if a >= 5:
        return "Wins the Exchange"
    if a >= 3:
        return "Wins a Piece"
    if a >= 1:
        return "Wins a Pawn"
    return "Opening Trap"


def make_title(opening, sans, meta, used):
    d = analyse(sans)
    if not d["legal"]:
        return None, d
    op = tidy_opening(opening)
    motif = motif_for(d)
    title = f"{op}: {motif}" if op else motif
    title = re.sub(r"\s+", " ", title).strip()

    if title in used:
        m = re.match(r"^\s*([A-Za-z\.\-' ]+?)\s*[-–]\s*([A-Za-z\.\-' ]+?)\s*,",
                     (meta or "").strip())
        if m:
            cand = f"{title} ({m.group(1).strip()}–{m.group(2).strip()})"
        else:
            cand = title
        if cand in used:
            n = 2
            base = cand
            while cand in used:
                cand = f"{base} #{n}"
                n += 1
        title = cand
    used.add(title)
    return title, d
