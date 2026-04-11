import type { Metadata, Viewport } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const viewport: Viewport = {
  themeColor: "#0a0a0a",
  width: "device-width",
  initialScale: 1,
};

export const metadata: Metadata = {
  title: {
    default: "Chess Traps - Master the Art of the Trap",
    template: "%s | Chess Traps",
  },
  metadataBase: new URL("https://chess-traps.vercel.app"),
  description: "Stop losing to early blunders. Learn over 1,000 professional chess traps with interactive practice, engine analysis, and master-level sequences.",
  keywords: ["chess traps", "chess openings", "chess tactics", "chess practice", "stockfish engine", "chess trainer"],
  authors: [{ name: "Achraf Cyber" }],
  creator: "Achraf Cyber",
  publisher: "Achraf Cyber",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  openGraph: {
    title: "Chess Traps - Master the Art of the Trap",
    description: "Learn over 1,000 professional chess traps with interactive practice and engine analysis.",
    url: "https://chess-traps.vercel.app",
    siteName: "Chess Traps",
    locale: "en_US",
    type: "website",
    images: [
      {
        url: "/hero.png",
        width: 1200,
        height: 800,
        alt: "Chess Traps - Master the Art of the Trap",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Chess Traps - Master the Art of the Trap",
    description: "Learn over 1,000 professional chess traps with interactive practice and engine analysis.",
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

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${geistSans.variable} ${geistMono.variable}`}>
      <body className="antialiased">{children}</body>
    </html>
  );
}
