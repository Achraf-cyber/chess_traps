import { Metadata } from "next";
import Link from "next/link";
import { popularTraps, trapsByOpening, SITE_URL, APP_NAME } from "@/lib/traps";

export const metadata: Metadata = {
  title: "All Chess Traps & Gambits — Complete List",
  description: `Browse every chess opening trap and gambit — from the Scholar's Mate and Fried Liver to the Danish Gambit. Learn each one and practice it in the ${APP_NAME} app.`,
  alternates: { canonical: `${SITE_URL}/traps` },
  openGraph: {
    title: "All Chess Traps & Gambits",
    description:
      "The complete library of chess opening traps — learn, practice and master them.",
    url: `${SITE_URL}/traps`,
    siteName: APP_NAME,
    type: "website",
    images: ["/hero.png"],
  },
};

export default function TrapsHub() {
  const popular = popularTraps(24);
  const groups = trapsByOpening();

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "All Chess Traps & Gambits",
    description: "The complete library of chess opening traps and gambits.",
    url: `${SITE_URL}/traps`,
  };

  return (
    <main className="hub-page">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />

      <header className="hub-header">
        <span className="trap-tag">Complete library · fully offline</span>
        <h1 className="hub-title">Chess Traps &amp; Gambits</h1>
        <p className="lede">
          The complete library of chess opening traps — from beginner classics
          like the Scholar&apos;s Mate to sharp master gambits. Tap any trap to
          learn it, then master it move-by-move in the {APP_NAME} app.
        </p>
      </header>

      <section className="trap-section">
        <h2>Most popular chess traps</h2>
        <div className="related-grid">
          {popular.map((t) => (
            <Link key={t.id} href={`/trap/${t.id}`} className="related-card">
              <span className="related-name">{t.trapName}</span>
              <span className="related-moves">{t.cleanMoves}</span>
            </Link>
          ))}
        </div>
      </section>

      <section className="trap-section">
        <h2>Browse by opening</h2>
        {groups.map((g) => (
          <div key={g.opening} className="opening-group">
            <h3 className="opening-name">
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
