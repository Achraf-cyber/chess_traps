import { Metadata } from "next";
import Link from "next/link";
import {
  APP_NAME,
  OG_IMAGE,
  popularTraps,
  SITE_URL,
  TRAP_TOTAL,
  trapsByOpening,
} from "@/lib/traps";

export const metadata: Metadata = {
  title: `All ${TRAP_TOTAL} Chess Traps, by Opening`,
  description: `Browse ${TRAP_TOTAL} chess opening traps by opening, from Scholar's Mate and the Fried Liver Attack to the Stafford Gambit, with the full moves of each one.`,
  alternates: { canonical: `${SITE_URL}/traps` },
  openGraph: {
    title: "All Chess Traps & Gambits",
    description:
      `${TRAP_TOTAL} chess opening traps, grouped by opening.`,
    url: `${SITE_URL}/traps`,
    siteName: APP_NAME,
    type: "website",
    images: [OG_IMAGE],
  },
};

export default function TrapsHub() {
  const popular = popularTraps(24);
  const groups = trapsByOpening();

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "All Chess Traps & Gambits",
    description: `${TRAP_TOTAL} chess opening traps, grouped by opening.`,
    url: `${SITE_URL}/traps`,
  };

  return (
    <main className="page">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c") }}
      />

      <span className="eyebrow">Complete library</span>
      <h1 className="heading-section" style={{ fontSize: "clamp(2.1rem, 6vw, 3rem)" }}>
        Every chess trap in {APP_NAME}
      </h1>
      <p className="lede">
        {TRAP_TOTAL} traps, from beginner classics to sharp gambits. Pick one to
        see its moves, or read a <Link href="/learn">full guide</Link> to the
        most popular ones.
      </p>

      <section className="section">
        <h2>Most popular</h2>
        <div className="card-grid">
          {popular.map((t) => (
            <Link key={t.id} href={`/trap/${t.id}`} className="card-link">
              <span className="card-title">{t.trapName}</span>
              <span className="card-meta">{t.cleanMoves}</span>
            </Link>
          ))}
        </div>
      </section>

      <section className="section">
        <h2>Browse by opening</h2>
        {groups.map((g) => (
          <div key={g.opening} className="opening-group">
            <h3>
              {g.opening}{" "}
              <span className="opening-count">({g.traps.length})</span>
            </h3>
            <ul className="opening-list">
              {g.traps.map((t) => (
                <li key={t.id}>
                  <Link href={`/trap/${t.id}`}>{t.trapName}</Link>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </section>
    </main>
  );
}
