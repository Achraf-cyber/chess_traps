import { Metadata } from "next";
import Link from "next/link";
import ChessDiagram from "@/components/ChessDiagram";
import { getArticles } from "@/lib/articles";
import { APP_NAME, OG_IMAGE, SITE_URL } from "@/lib/traps";

const title = "Chess Trap Guides: How They Work and How to Avoid Them";
const description =
  "Step-by-step guides to the most popular chess traps, from Scholar's Mate and the Fried Liver Attack to the Stafford Gambit, with boards, ideas and defences.";

export const metadata: Metadata = {
  title,
  description,
  alternates: { canonical: `${SITE_URL}/learn` },
  openGraph: {
    title,
    description,
    url: `${SITE_URL}/learn`,
    siteName: APP_NAME,
    type: "website",
    images: [OG_IMAGE],
  },
};

export default function LearnHub() {
  const articles = getArticles();
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: title,
    description,
    url: `${SITE_URL}/learn`,
    hasPart: articles.map((a) => ({
      "@type": "Article",
      headline: a.title,
      url: `${SITE_URL}/learn/${a.slug}`,
    })),
  };

  return (
    <main className="page">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c"),
        }}
      />
      <span className="eyebrow">Guides</span>
      <h1 className="heading-section" style={{ fontSize: "clamp(2.1rem, 6vw, 3rem)" }}>
        The chess traps worth knowing
      </h1>
      <p className="lede">
        How the most popular traps work, why they catch people, and what to do
        when one is set for you. New to this? Start with the{" "}
        <Link href="/learn/best-chess-traps">ten every player should know</Link>.
      </p>
      <div className="guide-list section">
        {articles.map((a) => (
          <Link key={a.slug} href={`/learn/${a.slug}`} className="guide-card">
            <ChessDiagram
              fen={a.boardFen}
              orientation={a.orientation}
              alt={`Position from the guide: ${a.headline}`}
            />
            <h2>{a.headline}</h2>
            <p>{a.intro.split(". ")[0]}.</p>
          </Link>
        ))}
      </div>
    </main>
  );
}
