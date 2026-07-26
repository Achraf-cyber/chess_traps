# Trap content pipeline

Regenerates the trap library from the raw sources. Run it whenever the source
data changes; the output is committed, so day-to-day development never needs it.

```bash
python tools/content/build_traps.py   # rebuild webpage/src/data/traps.json
python tools/content/gen_dart.py      # emit lib/generated/chess/base_chess_traps.dart
python tools/content/verify.py        # assert every invariant below
```

## What it fixes

The library was bulk-imported from PGN and the importer mis-read the headers:

* **716 traps were titled with something other than the trap** — the venue
  (`Dayton`, `Wijk aan Zee`, `Mountain View, CA`), the players
  (`Manko vs Jankowitz`), or decorative emoji. They now get a title describing
  what the line actually does, derived by replaying it: `Smothered Mate`,
  `Bxf7 Sacrifice & Mate`, `Black Queen Trap`, `Knight Fork`, `Wins a Piece`.
  The players are preserved in `metadata` instead of being thrown away.
* **The teaching commentary was dropped on import** — `commentedMoves` was a
  copy of `cleanMoves` for all 871 traps. 356 annotated lines are recovered
  from `master_traps.json`, e.g.
  `7.Rf1? [White must play 8.d4] ... 8.fxe5?? [White must return the Rook to h1]`.
* **Two traps had unplayable move lists** (swapped pairs / missing moves) and
  could never be replayed — the likely source of the `PlayException` crashes in
  Crashlytics. Repaired in place with verified lines.
* **85 traps present in the source were never imported**; they are appended.

## Invariants (enforced by `verify.py`)

1. **Index stability.** The app resolves traps as `chessTraps[index]`, and
   saved favourites, learned-trap ids and every `/trap/:id` deep link are
   positional. Original traps must keep their exact slot — new traps are only
   ever appended. `build_traps.py` asserts this.
2. **Legality.** Every shipped line is replayed with `python-chess`; the stored
   `fen` must equal the position reached. Nothing illegal can ship.
3. **Unique titles.** Duplicate titles are confusing in-app and fatal for SEO
   (every trap has its own indexed page).
4. **ECO opening names stay canonical.** `trapsGroupSource` groups traps by
   matching `trap.opening` against `lib/data/traps/openings.dart` *exactly*, so
   re-casing a name silently empties an opening group. Names are snapped back to
   the canonical ECO spelling.
