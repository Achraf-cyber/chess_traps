import { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import ChessDiagram from "@/components/ChessDiagram";
import OpenInApp from "@/components/OpenInApp";
import {
  getAllTraps,
  getTrap,
  seoTitle,
  seoDescription,
  explanationParagraphs,
  movePairs,
  moveCount,
  isMate,
  sideLabel,
  openingLabel,
  relatedTraps,
  SITE_URL,
  APP_NAME,
} from "@/lib/traps";

type Props = { params: Promise<{ id: string }> };

// Pre-render every trap page at build time (fast, fully indexable).
export function generateStaticParams() {
  return getAllTraps().map((t) => ({ id: String(t.id) }));
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params;
  const trap = getTrap(Number(id));
  if (!trap) return { title: "Trap not found" };

  const title = seoTitle(trap);
  const description = seoDescription(trap);
  const url = `${SITE_URL}/trap/${trap.id}`;

  return {
    title,
    description,
    keywords: [
      trap.trapName,
      openingLabel(trap),
      "chess trap",
      "chess opening trap",
      "chess gambit",
      "chess tactics",
      `${sideLabel(trap.targetSide)} wins`,
    ],
    alternates: { canonical: url },
    openGraph: {
      title,
      description,
      url,
      siteName: APP_NAME,
      type: "article",
      images: ["/hero.png"],
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
      images: ["/hero.png"],
    },
  };
}

export default async function TrapPage({ params }: Props) {
  const { id } = await params;
  const trap = getTrap(Number(id));
  if (!trap) notFound();

  const winner = sideLabel(trap.targetSide);
  const url = `${SITE_URL}/trap/${trap.id}`;
  const paragraphs = explanationParagraphs(trap);
  const pairs = movePairs(trap);
  const related = relatedTraps(trap);
  const opening = openingLabel(trap);

  // Structured data: Article + Breadcrumb (rich results eligibility).
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Article",
        headline: `${trap.trapName} — Chess Trap`,
        description: seoDescription(trap),
        author: { "@type": "Organization", name: APP_NAME },
        publisher: { "@type": "Organization", name: APP_NAME },
        mainEntityOfPage: url,
        about: opening,
      },
      {
        "@type": "BreadcrumbList",
        itemListElement: [
          { "@type": "ListItem", position: 1, name: "Home", item: SITE_URL },
          {
            "@type": "ListItem",
            position: 2,
            name: "Chess Traps",
            item: `${SITE_URL}/traps`,
          },
          {
            "@type": "ListItem",
            position: 3,
            name: trap.trapName,
            item: url,
          },
        ],
      },
    ],
  };

  return (
    <main className="trap-page">
      {/* `<` is escaped because trap names and opening labels come from the
          data file and land inside a <script> block: an unescaped "</script>"
          in any of them would break out of the tag. Next.js documents this
          replace as required, and it was missing. */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c"),
        }}
      />

      <nav className="trap-crumbs" aria-label="Breadcrumb">
        <Link href="/">Home</Link>
        <span>/</span>
        <Link href="/traps">Chess Traps</Link>
        <span>/</span>
        <span className="crumb-current">{trap.trapName}</span>
      </nav>

      <div className="trap-grid">
        <div className="trap-board">
          <ChessDiagram
            fen={trap.fen}
            alt={`Final position of the ${trap.trapName} — ${winner} wins`}
          />
          <p className="trap-board-cap">
            Final position — {winner}{" "}
            {isMate(trap) ? "delivers mate" : "is winning"}
          </p>
        </div>

        <div className="trap-head">
          <span className="trap-tag">{opening}</span>
          <h1 className="trap-title">{trap.trapName}</h1>
          <p className="trap-sub">
            {winner} wins in {moveCount(trap)} moves
            {isMate(trap) ? " by checkmate" : " with a decisive material gain"}.
            {trap.metadata ? ` (${trap.metadata})` : ""}
          </p>
          <OpenInApp trapId={trap.id} />
        </div>
      </div>

      <section className="trap-section">
        <h2>The moves</h2>
        <div className="move-line">{trap.cleanMoves}</div>
        <table className="move-table">
          <tbody>
            {pairs.map((p) => (
              <tr key={p.n}>
                <td className="mv-n">{p.n}.</td>
                <td className="mv-w">{p.white}</td>
                <td className="mv-b">{p.black ?? ""}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>

      <section className="trap-section">
        <h2>How the {trap.trapName} works</h2>
        {paragraphs.map((para, i) => (
          <p key={i} className="trap-para">
            {para}
          </p>
        ))}
      </section>

      <section className="trap-section trap-cta-band">
        <h2>Practice this trap move-by-move</h2>
        <p className="trap-para">
          Open the {trap.trapName} in the {APP_NAME} app to play it out on a live
          board, drill it in practice mode, and learn how to avoid it when
          it&apos;s set for you — along with the full library of chess traps and
          gambits, fully offline.
        </p>
        <OpenInApp trapId={trap.id} />
      </section>

      {related.length > 0 && (
        <section className="trap-section">
          <h2>More {opening} traps</h2>
          <div className="related-grid">
            {related.map((r) => (
              <Link key={r.id} href={`/trap/${r.id}`} className="related-card">
                <span className="related-name">{r.trapName}</span>
                <span className="related-moves">{r.cleanMoves}</span>
              </Link>
            ))}
          </div>
        </section>
      )}

      <div className="trap-foot">
        <Link href="/traps" className="btn-outline">
          ← Browse all chess traps
        </Link>
      </div>
    </main>
  );
}
