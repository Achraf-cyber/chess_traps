import React from "react";

// Black's glyph set for both sides: filled shapes take the side's colour, where
// the outline set can't be filled. The selector keeps ♟ out of emoji rendering.
const GLYPH: Record<string, string> = {
  k: "♚",
  q: "♛",
  r: "♜",
  b: "♝",
  n: "♞",
  p: "♟",
};

const LIGHT = "#f0d9b5";
const DARK = "#b58863";
const HIGHLIGHT = "rgba(155, 199, 0, 0.45)";
const SQUARE = 45;

/** A FEN as an inline SVG board: no client JS, no assets, readable by crawlers. */
export default function ChessDiagram({
  fen,
  alt,
  orientation = "white",
  lastMove,
}: {
  fen: string;
  alt: string;
  orientation?: "white" | "black";
  /** A UCI move, whose two squares are highlighted. */
  lastMove?: string;
}) {
  const flipped = orientation === "black";
  const place = (file: number, rank: number) => ({
    x: (flipped ? 7 - file : file) * SQUARE,
    y: (flipped ? 7 - rank : rank) * SQUARE,
  });

  const squares: React.ReactNode[] = [];
  for (let rank = 0; rank < 8; rank++) {
    for (let file = 0; file < 8; file++) {
      squares.push(
        <rect
          key={`${file}${rank}`}
          {...place(file, rank)}
          width={SQUARE}
          height={SQUARE}
          fill={(rank + file) % 2 === 0 ? LIGHT : DARK}
        />,
      );
    }
  }

  const highlights = (lastMove?.match(/[a-h][1-8]/g) ?? []).map((square) => (
    <rect
      key={square}
      {...place(square.charCodeAt(0) - 97, 8 - Number(square[1]))}
      width={SQUARE}
      height={SQUARE}
      fill={HIGHLIGHT}
    />
  ));

  const pieces: React.ReactNode[] = [];
  fen
    .split(" ")[0]
    .split("/")
    .forEach((row, rank) => {
      let file = 0;
      for (const ch of row) {
        if (/\d/.test(ch)) {
          file += Number(ch);
          continue;
        }
        const { x, y } = place(file, rank);
        const white = ch === ch.toUpperCase();
        pieces.push(
          <text
            key={`${file}${rank}`}
            x={x + SQUARE / 2}
            y={y + SQUARE / 2}
            fontSize={SQUARE * 0.86}
            textAnchor="middle"
            dominantBaseline="central"
            fill={white ? "#ffffff" : "#1c1a17"}
            stroke={white ? "#1c1a17" : "none"}
            strokeWidth={white ? 0.9 : 0}
          >
            {GLYPH[ch.toLowerCase()]}
            {"︎"}
          </text>,
        );
        file += 1;
      }
    });

  return (
    <div className="diagram">
      <svg viewBox={`0 0 ${SQUARE * 8} ${SQUARE * 8}`} role="img" aria-label={alt}>
        {squares}
        {highlights}
        {pieces}
      </svg>
    </div>
  );
}
