import type { Metadata, Viewport } from "next";
import { Newsreader, Public_Sans } from "next/font/google";
import Link from "next/link";
import { APP_NAME, OG_IMAGE, PLAY_URL, SITE_URL, TRAP_TOTAL } from "@/lib/traps";
import "./globals.css";

// The app's two families, self-hosted by next/font so that nothing blocks the
// first paint on a third-party request.
const newsreader = Newsreader({
  variable: "--font-display",
  subsets: ["latin"],
  weight: ["500", "600"],
  display: "swap",
});

const publicSans = Public_Sans({
  variable: "--font-body",
  subsets: ["latin"],
  weight: ["400", "600"],
  display: "swap",
});

export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#f7f2eb" },
    { media: "(prefers-color-scheme: dark)", color: "#161513" },
  ],
};

const SITE_TITLE = "Trapster: Learn Chess Opening Traps";
const SITE_DESCRIPTION = `Learn ${TRAP_TOTAL} chess opening traps on an interactive board. Practise them from memory, learn to avoid them, and check your ideas with Stockfish 19.`;

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: { default: SITE_TITLE, template: `%s | ${APP_NAME}` },
  description: SITE_DESCRIPTION,
  alternates: { canonical: SITE_URL },
  authors: [{ name: "Achraf Simbre" }],
  creator: "Achraf Simbre",
  publisher: "Achraf Simbre",
  formatDetection: { email: false, address: false, telephone: false },
  openGraph: {
    title: SITE_TITLE,
    description: SITE_DESCRIPTION,
    url: SITE_URL,
    siteName: APP_NAME,
    locale: "en_US",
    type: "website",
    images: [OG_IMAGE],
  },
  twitter: {
    card: "summary_large_image",
    title: SITE_TITLE,
    description: SITE_DESCRIPTION,
    images: [OG_IMAGE],
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

const jsonLd = [
  {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: APP_NAME,
    alternateName: "Trapster: Chess Opening Traps",
    applicationCategory: "GameApplication",
    applicationSubCategory: "Chess",
    operatingSystem: "Android",
    url: SITE_URL,
    downloadUrl: PLAY_URL,
    installUrl: PLAY_URL,
    description: SITE_DESCRIPTION,
    inLanguage: ["en", "fr", "es", "ar"],
    license: "https://www.gnu.org/licenses/gpl-3.0.html",
    isAccessibleForFree: true,
    // No aggregateRating: inventing one breaks Google's rules, so it waits for
    // real Play Store ratings.
    offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
    author: { "@type": "Person", name: "Achraf Simbre" },
  },
  {
    "@context": "https://schema.org",
    "@type": "WebSite",
    name: APP_NAME,
    url: SITE_URL,
    inLanguage: "en",
  },
];

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${newsreader.variable} ${publicSans.variable}`}>
      <body>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c"),
          }}
        />
        <a className="skip-link" href="#content">
          Skip to content
        </a>
        <header className="site-header">
          <div className="site-header-inner">
            <Link href="/" className="logo">
              {APP_NAME}
            </Link>
            <nav className="site-nav" aria-label="Main">
              <Link href="/learn">Guides</Link>
              <Link href="/traps">All traps</Link>
              <a href={PLAY_URL} className="btn-primary">
                Get the app
              </a>
            </nav>
          </div>
        </header>
        <div id="content">{children}</div>
        <footer className="site-footer">
          <div className="site-footer-inner">
            <span>&copy; 2026 Achraf Simbre</span>
            <nav aria-label="Footer">
              <Link href="/learn">Guides</Link>
              <Link href="/traps">All traps</Link>
              <a href="https://achraf-cyber.github.io/privacy/privacy-policy.html">
                Privacy
              </a>
              <Link href="/terms">Terms</Link>
              <a href="mailto:achrafsimbre@gmail.com">Contact</a>
            </nav>
          </div>
        </footer>
      </body>
    </html>
  );
}
