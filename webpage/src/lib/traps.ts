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

export const TRAP_TOTAL = traps.length;

/** The share image, for pages whose own openGraph replaces the inherited one. */
export const OG_IMAGE = "/opengraph-image";

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

/** <title>, kept short enough that the name isn't cut off in search results. */
export function seoTitle(trap: Trap): string {
  const name = trap.trapName.trim();
  const op = (trap.opening || "").trim();
  const withOpening = `${name}: ${op}`;
  if (op && withOpening.length <= 50) return withOpening;
  return /trap|mate/i.test(name) ? name : `${name} Trap`;
}

/** Meta description: the real moves, so that each one is unique. */
export function seoDescription(trap: Trap): string {
  const op = (trap.opening || "").trim();
  const place = op ? ` in the ${op}` : "";
  const end = isMate(trap) ? "checkmate" : "the final position";
  return `The ${trap.trapName}${place}, a trap for ${sideLabel(trap.targetSide)}: ${trap.cleanMoves}. See the moves to ${end} and practise them in ${APP_NAME}.`.slice(
    0,
    300,
  );
}

/** A short explanation from the trap's own data, claiming nothing beyond it. */
export function explanationParagraphs(trap: Trap): string[] {
  const side = sideLabel(trap.targetSide);
  const other = sideLabel(trap.targetSide === "white" ? "black" : "white");
  const op = (trap.opening || "").trim();
  const ending = isMate(trap)
    ? `ends in checkmate on move ${moveCount(trap)}`
    : `runs for ${moveCount(trap)} moves`;

  const paragraphs = [
    `The ${trap.trapName} is a trap for ${side}${
      op ? ` from the ${op}` : ""
    }. The line ${ending}: ${trap.cleanMoves}.`,
    `If you play ${side}, this is a sequence to steer towards. If you play ${other}, look at where the line goes wrong and find a different move before you reach that point. ${APP_NAME}'s Avoid mode drills exactly that.`,
  ];
  if (trap.metadata.trim()) {
    paragraphs.push(`Recorded from the game ${trap.metadata.trim()}.`);
  }
  return paragraphs;
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
