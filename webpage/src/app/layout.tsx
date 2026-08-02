import type { Metadata, Viewport } from "next";
import { Outfit, Syne } from "next/font/google";
import "./globals.css";

// These are the two families globals.css actually styles with. They used to be
// pulled in by an `@import url(fonts.googleapis.com)` at the top of the
// stylesheet, which blocks the first paint on a third-party round trip, while
// next/font separately downloaded Geist that nothing ever referenced. Loading
// them here self-hosts the files and removes both problems.
const outfit = Outfit({
  variable: "--font-body",
  subsets: ["latin"],
  weight: ["300", "400", "600", "800"],
  display: "swap",
});

const syne = Syne({
  variable: "--font-display",
  subsets: ["latin"],
  weight: ["700", "800"],
  display: "swap",
});

export const viewport: Viewport = {
  themeColor: "#0a0a0a",
  width: "device-width",
  initialScale: 1,
};

export const metadata: Metadata = {
  title: {
    default: "Trapster — Master Chess Traps & Gambits",
    template: "%s | Trapster",
  },
  metadataBase: new URL("https://chess-traps.vercel.app"),
  description:
    "Stop losing to early blunders. Learn and practice chess opening traps and gambits with an interactive board, engine analysis and offline play — the Trapster app.",
  keywords: [
    "chess traps",
    "chess opening traps",
    "chess gambits",
    "chess openings",
    "chess tactics",
    "learn chess",
    "chess trainer",
    "Trapster",
  ],
  authors: [{ name: "Achraf Cyber" }],
  creator: "Achraf Cyber",
  publisher: "Achraf Cyber",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  openGraph: {
    title: "Trapster — Master Chess Traps & Gambits",
    description:
      "Learn and practice chess opening traps and gambits with an interactive board and engine analysis.",
    url: "https://chess-traps.vercel.app",
    siteName: "Trapster",
    locale: "en_US",
    type: "website",
    images: [
      {
        url: "/hero.png",
        width: 1200,
        height: 800,
        alt: "Trapster — Master Chess Traps & Gambits",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Trapster — Master Chess Traps & Gambits",
    description:
      "Learn and practice chess opening traps and gambits with an interactive board and engine analysis.",
    images: ["/hero.png"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
};

// Structured data. Google reads this to decide whether the site earns a rich
// result; without it a page is just prose to a crawler. SoftwareApplication is
// the type that can surface the rating, price and platform directly in search.
const appJsonLd = {
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  name: "Trapster",
  alternateName: "Trapster: Chess Opening Traps",
  applicationCategory: "GameApplication",
  applicationSubCategory: "Chess",
  operatingSystem: "Android",
  url: "https://chess-traps.vercel.app",
  downloadUrl:
    "https://play.google.com/store/apps/details?id=chesstraps.achrafcyber.com",
  installUrl:
    "https://play.google.com/store/apps/details?id=chesstraps.achrafcyber.com",
  description:
    "Learn and practice chess opening traps and gambits with an interactive board, Stockfish analysis and full offline play.",
  inLanguage: ["en", "fr", "es", "ar"],
  license: "https://www.gnu.org/licenses/gpl-3.0.html",
  isAccessibleForFree: true,
  // No aggregateRating: the app has no ratings yet, and inventing one is both
  // a policy violation and grounds for a manual action.
  offers: {
    "@type": "Offer",
    price: "0",
    priceCurrency: "USD",
  },
  author: {
    "@type": "Person",
    name: "Achraf Simbre",
  },
};

const siteJsonLd = {
  "@context": "https://schema.org",
  "@type": "WebSite",
  name: "Trapster",
  url: "https://chess-traps.vercel.app",
  inLanguage: "en",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${outfit.variable} ${syne.variable}`}>
      <body className="antialiased">
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify([appJsonLd, siteJsonLd]).replace(
              /</g,
              "\\u003c",
            ),
          }}
        />
        {children}
      </body>
    </html>
  );
}
