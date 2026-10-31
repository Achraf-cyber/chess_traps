import articlesData from "@/data/articles.json";

export type ArticleBlock =
  | { type: "p" | "h2"; text: string }
  | { type: "ul"; items: string[] }
  | {
      type: "board";
      fen: string;
      line: string;
      lastMove: string;
      caption: string;
      orientation: "white" | "black";
    };

export type Article = {
  slug: string;
  trapId: number | null;
  title: string;
  headline: string;
  description: string;
  intro: string;
  orientation: "white" | "black";
  published: string;
  blocks: ArticleBlock[];
  faq: { q: string; a: string }[];
  /** The position a card shows: the last board in the guide's main line. */
  boardFen: string;
};

const INITIAL_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

const articles: Article[] = (articlesData as Omit<Article, "boardFen">[]).map(
  (article) => {
    const boards = article.blocks.filter((b) => b.type === "board");
    const main = boards.reduce(
      (longest, b) =>
        longest && longest.line.length >= b.line.length ? longest : b,
      boards[0],
    );
    return { ...article, boardFen: main?.fen ?? INITIAL_FEN };
  },
);

export function getArticles(): Article[] {
  return articles;
}

export function getArticle(slug: string): Article | undefined {
  return articles.find((a) => a.slug === slug);
}

export function articleForTrap(trapId: number): Article | undefined {
  return articles.find((a) => a.trapId === trapId);
}

/** Markup stripped, for structured data. */
export function plainText(text: string): string {
  return text.replace(/\*\*/g, "").replace(/\[([^\]]+)\]\([^)]+\)/g, "$1");
}
