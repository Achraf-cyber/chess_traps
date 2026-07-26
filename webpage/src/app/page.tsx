import Image from "next/image";
import Link from "next/link";
import { popularTraps } from "@/lib/traps";

const PLAY_STORE_URL =
  "https://play.google.com/store/apps/details?id=chesstraps.achrafcyber.com";

export default function Home() {
  return (
    <main className="relative min-h-screen">
      {/* Navigation */}
      <nav className="nav">
        <div className="logo">Trapster</div>
        <div className="flex gap-8 items-center">
          <Link href="/traps" className="btn-outline hidden md:flex">Browse Traps</Link>
          <Link href={PLAY_STORE_URL} className="btn-primary">
            Download
          </Link>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="section-hero">
        <div className="reveal" style={{ animationDelay: '0.1s' }}>
          <h1 className="heading-hero">
            ELEVATE YOUR <br />
            <span className="accent-text">CHESS GAME</span>
          </h1>
          <p className="lede">
            Learn chess opening traps and gambits with an interactive board, play
            them out live against Stockfish, and get a hint or a plain-English
            explanation whenever you get stuck.
          </p>
          <div className="cta-row">
            <Link href={PLAY_STORE_URL} className="btn-primary">
              Get it on Google Play
            </Link>
            <Link href="/traps" className="btn-outline">
              Browse All Traps
            </Link>
          </div>
        </div>

        {/* Hero Image Mockup */}
        <div className="hero-image-wrap reveal" style={{ animationDelay: '0.3s' }}>
          <Image
            src="/hero.png"
            alt="Trapster app — chess trap library and interactive board"
            width={1200}
            height={800}
            priority
            className="w-full h-auto opacity-80"
          />
        </div>

        {/* Floating Stats */}
        <div className="floating-stats reveal" style={{ animationDelay: '0.5s' }}>
          <div className="stat-item">
            <span className="stat-value">FREE</span>
            <span className="stat-label">No Subscription</span>
          </div>
          <div className="stat-item">
            <span className="stat-value">24/7</span>
            <span className="stat-label">Engine Access</span>
          </div>
          <div className="stat-item">
            <span className="stat-value">4</span>
            <span className="stat-label">Languages</span>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="grid-features">
        <div className="feature-card reveal" style={{ animationDelay: '0.1s' }}>
          <span className="icon">♟️</span>
          <h3>Interactive Training</h3>
          <p>
            Don&apos;t just memorize. Play through every trap on an interactive board that
            guides you through the winning moves, with per-move explanations of why each
            one works.
          </p>
        </div>

        <div className="feature-card reveal" style={{ animationDelay: '0.2s' }}>
          <span className="icon">♞</span>
          <h3>Play Stockfish</h3>
          <p>
            Play a full game against the Stockfish engine at any strength, get a hint when
            you&apos;re unsure of the best move, and review what happened move-by-move once
            the game ends.
          </p>
        </div>

        <div className="feature-card reveal" style={{ animationDelay: '0.3s' }}>
          <span className="icon">📈</span>
          <h3>Personal Progress</h3>
          <p>
            Track your mastery. Mark traps as learned, revisit your saved games any time,
            and build a repertoire you actually remember over the board.
          </p>
        </div>
      </section>

      {/* Popular traps — internal links so crawlers reach the library fast */}
      <section className="trap-page" style={{ paddingTop: 0 }}>
        <h2 className="heading-section">Popular chess traps</h2>
        <div className="related-grid">
          {popularTraps(12).map((t) => (
            <Link key={t.id} href={`/trap/${t.id}`} className="related-card">
              <span className="related-name">{t.trapName}</span>
              <span className="related-moves">{t.cleanMoves}</span>
            </Link>
          ))}
        </div>
        <div style={{ marginTop: "2rem" }}>
          <Link href="/traps" className="btn-outline">
            Browse all traps →
          </Link>
        </div>
      </section>

      {/* Final CTA */}
      <section className="section-cta reveal">
        <h2 className="heading-section">Ready to dominate?</h2>
        <Link href={PLAY_STORE_URL} className="btn-primary">
          Start Training Now
        </Link>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="footer-inner">
          <div className="footer-logo logo">Trapster</div>
          <div className="footer-links">
            <Link href="https://achraf-cyber.github.io/privacy/privacy-policy.html">
              Privacy
            </Link>
            <Link href="/terms">Terms</Link>
            <Link href="mailto:achrafsimbre@gmail.com">Contact</Link>
          </div>
          <p className="footer-copy">&copy; 2026 Achraf Cyber.</p>
        </div>
      </footer>
    </main>
  );
}
