import { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import ChessDiagram from "@/components/ChessDiagram";
import OpenInApp from "@/components/OpenInApp";
import RichText from "@/components/RichText";
import { getArticle, getArticles, plainText } from "@/lib/articles";
import { APP_NAME, getTrap, SITE_URL } from "@/lib/traps";

type Props = { params: Promise<{ slug: string }> };

export const dynamicParams = false;

export function generateStaticParams() {
  return getArticles().map((a) => ({ slug: a.slug }));
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const article = getArticle(slug);
  if (!article) return { title: "Guide not found" };

  const url = `${SITE_URL}/learn/${article.slug}`;
  return {
    // The titles are complete already, so the site name isn't added to them.
    title: { absolute: article.title },
    description: article.description,
    alternates: { canonical: url },
    openGraph: {
      title: article.title,
      description: article.description,
      url,
      siteName: APP_NAME,
      type: "article",
      publishedTime: article.published,
    },
    twitter: {
      card: "summary_large_image",
      title: article.title,
      description: article.description,
    },
  };
}

export default async function ArticlePage({ params }: Props) {
  const { slug } = await params;
  const article = getArticle(slug);
  if (!article) notFound();

  const url = `${SITE_URL}/learn/${article.slug}`;
  const trap = article.trapId === null ? undefined : getTrap(article.trapId);
  const others = getArticles()
    .filter((a) => a.slug !== article.slug)
    .slice(0, 4);

  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Article",
        headline: article.title,
        description: article.description,
        datePublished: article.published,
        dateModified: article.published,
        image: `${url}/opengraph-image`,
        author: { "@type": "Organization", name: APP_NAME, url: SITE_URL },
        publisher: { "@type": "Organization", name: APP_NAME, url: SITE_URL },
        mainEntityOfPage: url,
      },
      {
        "@type": "BreadcrumbList",
        itemListElement: [
          { "@type": "ListItem", position: 1, name: "Home", item: SITE_URL },
          {
            "@type": "ListItem",
            position: 2,
            name: "Guides",
            item: `${SITE_URL}/learn`,
          },
          {
            "@type": "ListItem",
            position: 3,
            name: article.headline,
            item: url,
          },
        ],
      },
      {
        "@type": "FAQPage",
        mainEntity: article.faq.map(({ q, a }) => ({
          "@type": "Question",
          name: q,
          acceptedAnswer: { "@type": "Answer", text: plainText(a) },
        })),
      },
    ],
  };

  return (
    <main className="page narrow">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c"),
        }}
      />
      <nav className="crumbs" aria-label="Breadcrumb">
        <Link href="/">Home</Link>
        <span>/</span>
        <Link href="/learn">Guides</Link>
        <span>/</span>
        <span>{article.headline}</span>
      </nav>

      <article>
        <header className="article-head">
          <h1>{article.title}</h1>
          <p className="lede">{article.intro}</p>
        </header>

        <div className="article-body">
          {article.blocks.map((block, i) => {
            switch (block.type) {
              case "h2":
                return <h2 key={i}>{block.text}</h2>;
              case "p":
                return (
                  <p key={i}>
                    <RichText text={block.text} />
                  </p>
                );
              case "ul":
                return (
                  <ul key={i}>
                    {block.items.map((item) => (
                      <li key={item}>
                        <RichText text={item} />
                      </li>
                    ))}
                  </ul>
                );
              case "board":
                return (
                  <figure key={i} className="board">
                    <ChessDiagram
                      fen={block.fen}
                      orientation={block.orientation}
                      lastMove={block.lastMove}
                      alt={`Chess board after ${block.line}. ${block.caption}`}
                    />
                    <figcaption>
                      <span className="notation">{block.line}</span>
                      {block.caption}
                    </figcaption>
                  </figure>
                );
            }
          })}

          <h2>Common questions</h2>
          {article.faq.map(({ q, a }) => (
            <div key={q}>
              <h3>{q}</h3>
              <p>
                <RichText text={a} />
              </p>
            </div>
          ))}
        </div>
      </article>

      <section className="article-cta">
        {trap ? (
          <>
            <h2>Practise it until it sticks</h2>
            <p>
              Reading a line isn&apos;t the same as finding it at the board. Play{" "}
              {article.headline} move by move in {APP_NAME}, from both sides,
              with Stockfish on hand.
            </p>
            <OpenInApp trapId={trap.id} />
          </>
        ) : (
          <>
            <h2>Practise every trap on a real board</h2>
            <p>
              {APP_NAME} is free on Android, with all these traps and hundreds
              more.
            </p>
            <OpenInApp />
          </>
        )}
      </section>

      <section className="section">
        <h2>Keep reading</h2>
        <div className="card-grid">
          {others.map((a) => (
            <Link key={a.slug} href={`/learn/${a.slug}`} className="card-link">
              <span className="card-title">{a.headline}</span>
            </Link>
          ))}
        </div>
      </section>
    </main>
  );
}
