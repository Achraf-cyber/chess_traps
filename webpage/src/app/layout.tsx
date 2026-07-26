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
