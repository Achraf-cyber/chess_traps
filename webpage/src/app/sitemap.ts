import { MetadataRoute } from "next";
import { getAllTraps } from "@/lib/traps";

const baseUrl = "https://chess-traps.vercel.app";

// Sourced from the same canonical data the trap pages render, so it can never
// drift out of sync with the actual number of generated pages.
const TRAP_COUNT = getAllTraps().length;

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
      url: `${baseUrl}/traps`,
      lastModified,
      changeFrequency: "weekly",
      priority: 0.9,
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
