import { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Trapster: Chess Traps",
    short_name: "Trapster",
    description:
      "Learn and practise chess opening traps on an interactive board.",
    start_url: "/",
    display: "standalone",
    background_color: "#f7f2eb",
    theme_color: "#2f5d48",
    icons: [
      { src: "/icon-192.png", sizes: "192x192", type: "image/png" },
      { src: "/icon-512.png", sizes: "512x512", type: "image/png" },
    ],
  };
}
