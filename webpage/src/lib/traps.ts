import trapsData from "@/data/traps.json";

export type Trap = {
  id: number;
  opening: string;
  openingId: string;
  trapName: string;
  trapNameFr: string;
  trapNameEs: string;
  trapNameAr: string;
  cleanMoves: string;
  commentedMoves: string;
  metadata: string;
  fen: string;
  moves: string[];
  targetSide: "white" | "black";
};

export const SITE_URL = "https://chess-traps.vercel.app";
export const APP_NAME = "Trapster";
export const PACKAGE = "chesstraps.achrafcyber.com";
export const PLAY_URL = `https://play.google.com/store/apps/details?id=${PACKAGE}`;

const traps = trapsData as Trap[];

export function getAllTraps(): Trap[] {
  return traps;
}

export function getTrap(id: number): Trap | undefined {
  return traps[id]?.id === id ? traps[id] : traps.find((t) => t.id === id);
}

export function sideLabel(side: string): string {
  return side === "white" ? "White" : "Black";
}

/** Human, SEO-friendly move count phrase. */
export function moveCount(trap: Trap): number {
  return Math.ceil(trap.moves.length / 2);
}

/** True when the trap ends in checkmate (last move carries '#'). */
export function isMate(trap: Trap): boolean {
  const last = trap.moves[trap.moves.length - 1] ?? "";
  return last.includes("#");
}

/** Numbered move pairs for a readable notation table. */
export function movePairs(
  trap: Trap,
): { n: number; white: string; black?: string }[] {
  const pairs: { n: number; white: string; black?: string }[] = [];
  for (let i = 0; i < trap.moves.length; i += 2) {
    pairs.push({
      n: i / 2 + 1,
      white: trap.moves[i],
      black: trap.moves[i + 1],
    });
  }
  return pairs;
}

/** A clean opening label, falling back gracefully when the field is empty. */
export function openingLabel(trap: Trap): string {
  const o = (trap.opening || "").trim();
  return o.length > 0 ? o : "Chess Opening";
}

/** <title> — unique per trap, keyword-front-loaded, under ~60 chars where possible. */
export function seoTitle(trap: Trap): string {
  const name = trap.trapName.trim();
  const op = (trap.opening || "").trim();
  if (op && !name.toLowerCase().includes(op.toLowerCase().split(" ")[0])) {
    return `${name} — ${op} Trap`;
  }
  return `${name} — Chess Trap`;
}

/** Meta description — real moves + outcome, keyword-rich, ~150 chars. */
export function seoDescription(trap: Trap): string {
  const winner = sideLabel(trap.targetSide);
  const finish = isMate(trap) ? "checkmate" : "a winning position";
  const op = (trap.opening || "").trim();
  const opPart = op ? ` in the ${op}` : "";
  return `Learn the ${trap.trapName}${opPart}: ${trap.cleanMoves} — ${winner} reaches ${finish} in ${moveCount(
    trap,
  )} moves. Play it move-by-move in the ${APP_NAME} app.`.slice(0, 300);
}

/** A short, unique multi-paragraph explanation built from the trap's own data. */
export function explanationParagraphs(trap: Trap): string[] {
  const winner = sideLabel(trap.targetSide);
  const loser = sideLabel(trap.targetSide === "white" ? "black" : "white");
  const op = (trap.opening || "").trim();
  const finish = isMate(trap)
    ? `delivers checkmate on move ${moveCount(trap)}`
    : `wins decisive material by move ${moveCount(trap)}`;

  const p1 = `The ${trap.trapName} is a classic chess opening trap${
    op ? ` arising from the ${op}` : ""
  }. In this line ${winner} ${finish}, punishing a natural-looking but losing idea from ${loser}.`;

  const p2 = `The full sequence runs ${trap.cleanMoves}. Each move looks reasonable, which is exactly why the trap is so effective over the board — ${loser} walks into it while trying to play "normal" developing moves.`;

  const p3 =
    trap.metadata && trap.metadata.trim().length > 0
      ? `This pattern is well known from master and correspondence play (${trap.metadata.trim()}). Recognising it early lets you either spring it as ${winner} or sidestep it as ${loser}.`
      : `Recognising this pattern early lets you either spring it as ${winner} or calmly sidestep it when you are ${loser}.`;

  return [p1, p2, p3];
}

const POPULAR_KEYWORDS = [
  "Scholar",
  "Fool",
  "Légal",
  "Legal",
  "Fried Liver",
  "Fishing Pole",
  "Blackburne",
  "Englund",
  "Lasker",
  "Elephant",
  "Halosar",
  "Traxler",
  "Noah",
  "Magnus",
  "Lolli",
  "Cambridge",
  "Monkey",
  "Bxf7",
  "Smothered",
];

/** A curated set of the most-searched traps for internal linking / discovery. */
export function popularTraps(limit = 24): Trap[] {
  const picked: Trap[] = [];
  const seen = new Set<number>();
  for (const kw of POPULAR_KEYWORDS) {
    const found = traps.find(
      (t) =>
        !seen.has(t.id) &&
        t.trapName.toLowerCase().includes(kw.toLowerCase()),
    );
    if (found) {
      picked.push(found);
      seen.add(found.id);
    }
  }
  // Top up with early (well-formed) traps to reach the limit.
  for (const t of traps) {
    if (picked.length >= limit) break;
    if (!seen.has(t.id) && t.trapName && t.opening) {
      picked.push(t);
      seen.add(t.id);
    }
  }
  return picked.slice(0, limit);
}

/** Other traps sharing the same opening, for "related" internal links. */
export function relatedTraps(trap: Trap, limit = 6): Trap[] {
  return traps
    .filter(
      (t) =>
        t.id !== trap.id &&
        t.openingId &&
        t.openingId === trap.openingId,
    )
    .slice(0, limit);
}

/** Traps grouped by opening, for the /traps hub. */
export function trapsByOpening(): { opening: string; traps: Trap[] }[] {
  const map = new Map<string, Trap[]>();
  for (const t of traps) {
    const key = openingLabel(t);
    if (!map.has(key)) map.set(key, []);
    map.get(key)!.push(t);
  }
  return Array.from(map.entries())
    .map(([opening, ts]) => ({ opening, traps: ts }))
    .sort((a, b) => b.traps.length - a.traps.length);
}
