import { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import ChessDiagram from "@/components/ChessDiagram";
import OpenInApp from "@/components/OpenInApp";
import { articleForTrap } from "@/lib/articles";
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
  OG_IMAGE,
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
    alternates: { canonical: url },
    openGraph: {
      title,
      description,
      url,
      siteName: APP_NAME,
      type: "article",
      images: [OG_IMAGE],
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
      images: [OG_IMAGE],
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
  const guide = articleForTrap(trap.id);

  // Structured data: Article + Breadcrumb (rich results eligibility).
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Article",
        headline: seoTitle(trap),
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
    <main className="page">
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

      <nav className="crumbs" aria-label="Breadcrumb">
        <Link href="/">Home</Link>
        <span>/</span>
        <Link href="/traps">Chess traps</Link>
        <span>/</span>
        <span>{trap.trapName}</span>
      </nav>

      <div className="trap-grid">
        <ChessDiagram
          fen={trap.fen}
          orientation={trap.targetSide}
          alt={`Final position of the ${trap.trapName}`}
        />
        <div>
          <span className="eyebrow">{opening}</span>
          <h1>{trap.trapName}</h1>
          <p className="trap-sub">
            A trap for {winner}, {moveCount(trap)} moves long
            {isMate(trap) ? ", ending in checkmate" : ""}.
          </p>
          <OpenInApp trapId={trap.id} />
        </div>
      </div>

      <section className="section">
        <h2>The moves</h2>
        <table className="move-table">
          <tbody>
            {pairs.map((p) => (
              <tr key={p.n}>
                <td className="mv-n">{p.n}.</td>
                <td>{p.white}</td>
                <td>{p.black ?? ""}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>

      <section className="section prose-block">
        <h2>How it works</h2>
        {paragraphs.map((para) => (
          <p key={para}>{para}</p>
        ))}
        {guide && (
          <p>
            Read the full guide:{" "}
            <Link href={`/learn/${guide.slug}`}>{guide.title}</Link>
          </p>
        )}
      </section>

      {related.length > 0 && (
        <section className="section">
          <h2>More {opening} traps</h2>
          <div className="card-grid">
            {related.map((r) => (
              <Link key={r.id} href={`/trap/${r.id}`} className="card-link">
                <span className="card-title">{r.trapName}</span>
                <span className="card-meta">{r.cleanMoves}</span>
              </Link>
            ))}
          </div>
        </section>
      )}
    </main>
  );
}
