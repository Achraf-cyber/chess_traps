import React from "react";

const GLYPH: Record<string, string> = {
  K: "♔",
  Q: "♕",
  R: "♖",
  B: "♗",
  N: "♘",
  P: "♙",
  k: "♚",
  q: "♛",
  r: "♜",
  b: "♝",
  n: "♞",
  p: "♟",
};

const LIGHT = "#EBECD0";
const DARK = "#B58863";
const FILES = ["a", "b", "c", "d", "e", "f", "g", "h"];

/**
 * Renders the final position of a trap from its FEN as an inline, crawlable
 * SVG board. No client JS, no external assets — good for LCP and for OG.
 */
export default function ChessDiagram({
  fen,
  size = 360,
  alt,
}: {
  fen: string;
  size?: number;
  alt?: string;
}) {
  const placement = fen.split(" ")[0];
  const rows = placement.split("/");
  const sq = size / 8;
  const cells: React.ReactNode[] = [];

  rows.forEach((row, r) => {
    let file = 0;
    for (const ch of row) {
      if (/\d/.test(ch)) {
        file += parseInt(ch, 10);
        continue;
      }
      const x = file * sq;
      const y = r * sq;
      const isLight = (r + file) % 2 === 0;
      cells.push(
        <rect
          key={`s-${r}-${file}`}
          x={x}
          y={y}
          width={sq}
          height={sq}
          fill={isLight ? LIGHT : DARK}
        />,
      );
      const glyph = GLYPH[ch];
      if (glyph) {
        const white = ch === ch.toUpperCase();
        cells.push(
          <text
            key={`p-${r}-${file}`}
            x={x + sq / 2}
            y={y + sq / 2}
            fontSize={sq * 0.82}
            textAnchor="middle"
            dominantBaseline="central"
            fill={white ? "#ffffff" : "#111111"}
            stroke={white ? "#111111" : "none"}
            strokeWidth={white ? 0.6 : 0}
          >
            {glyph}
          </text>,
        );
      }
      file += 1;
    }
  });

  // Empty background squares for files skipped via digits are already covered
  // because we only draw occupied files; add a full base board underneath.
  const base: React.ReactNode[] = [];
  for (let r = 0; r < 8; r++) {
    for (let f = 0; f < 8; f++) {
      base.push(
        <rect
          key={`b-${r}-${f}`}
          x={f * sq}
          y={r * sq}
          width={sq}
          height={sq}
          fill={(r + f) % 2 === 0 ? LIGHT : DARK}
        />,
      );
    }
  }

  return (
    <svg
      viewBox={`0 0 ${size} ${size}`}
      width="100%"
      height="100%"
      role="img"
      aria-label={alt ?? "Chess trap final position"}
      style={{ display: "block", borderRadius: 8, maxWidth: size }}
    >
      {base}
      {cells}
      {FILES.map((f, i) => (
        <text
          key={`f-${f}`}
          x={i * sq + sq * 0.12}
          y={size - sq * 0.08}
          fontSize={sq * 0.16}
          fill={(7 + i) % 2 === 0 ? DARK : LIGHT}
          opacity={0.9}
        >
          {f}
        </text>
      ))}
    </svg>
  );
}
