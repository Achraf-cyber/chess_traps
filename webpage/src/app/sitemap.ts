import { MetadataRoute } from "next";

const baseUrl = "https://chess-traps.vercel.app";

// Keep in sync with the trap count shipped in the app
// (lib/generated/chess/base_chess_traps.dart, ids 0..870).
const TRAP_COUNT = 871;

export default function sitemap(): MetadataRoute.Sitemap {
  const lastModified = new Date();

  const staticRoutes: MetadataRoute.Sitemap = [
    {
      url: baseUrl,
      lastModified,
      changeFrequency: "monthly",
      priority: 1,
    },
    {
      url: `${baseUrl}/terms`,
      lastModified,
      changeFrequency: "yearly",
      priority: 0.3,
    },
  ];

  const trapRoutes: MetadataRoute.Sitemap = Array.from(
    { length: TRAP_COUNT },
    (_, id) => ({
      url: `${baseUrl}/trap/${id}`,
      lastModified,
      changeFrequency: "monthly" as const,
      priority: 0.6,
    }),
  );

  return [...staticRoutes, ...trapRoutes];
}
