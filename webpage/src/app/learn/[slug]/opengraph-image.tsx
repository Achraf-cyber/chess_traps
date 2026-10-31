import { ImageResponse } from "next/og";
import { getArticle, getArticles } from "@/lib/articles";

export const alt = "Trapster chess trap guide";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export function generateStaticParams() {
  return getArticles().map((a) => ({ slug: a.slug }));
}

export default async function Image({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const article = getArticle(slug);

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: 72,
          background: "#f7f2eb",
          color: "#1c1a17",
        }}
      >
        <div style={{ fontSize: 34, color: "#2f5d48" }}>Trapster guides</div>
        <div style={{ fontSize: 80, lineHeight: 1.1 }}>{article?.headline}</div>
        <div style={{ fontSize: 30, color: "#5f5a52" }}>
          How it works, and how to avoid it
        </div>
      </div>
    ),
    size,
  );
}
