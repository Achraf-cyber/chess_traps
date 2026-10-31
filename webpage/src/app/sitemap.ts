import { MetadataRoute } from "next";
import { getArticles } from "@/lib/articles";
import { getAllTraps, SITE_URL } from "@/lib/traps";

// When the content last changed. A build date here would tell crawlers that
// every page changes on every deploy, and they learn to ignore that.
const LAST_UPDATED = "2026-10-31";

export default function sitemap(): MetadataRoute.Sitemap {
  const page = (path: string, priority: number) => ({
    url: `${SITE_URL}${path}`,
    lastModified: LAST_UPDATED,
    priority,
  });

  return [
    page("", 1),
    page("/learn", 0.9),
    page("/traps", 0.9),
    ...getArticles().map((a) => page(`/learn/${a.slug}`, 0.8)),
    ...getAllTraps().map((t) => page(`/trap/${t.id}`, 0.5)),
    page("/terms", 0.2),
  ];
}
