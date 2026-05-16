import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <main className="relative min-h-screen">
      {/* Navigation */}
      <nav className="nav">
        <div className="logo">Chess Traps</div>
        <div className="flex gap-8 items-center">
          <Link href="#features" className="btn-outline hidden md:flex">Features</Link>
          <Link href="https://play.google.com/store/apps/details?id=chesstraps.achrafcyber.com" className="btn-primary">
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
          <p className="max-w-2xl mx-auto text-xl text-[#888] leading-relaxed mb-10">
            Uncover the secrets of the world's most effective chess traps. 
            Interactive practice, real-time engine analysis, and over 1,000 patterns.
          </p>
          <div className="flex flex-wrap justify-center gap-4">
            <Link href="https://play.google.com/store/apps/details?id=chesstraps.achrafcyber.com" className="btn-primary">
              Get it on Google Play
            </Link>
            <Link href="#features" className="btn-outline">
              Explore Features
            </Link>
          </div>
        </div>

        {/* Hero Image Mockup */}
        <div className="hero-image-wrap reveal" style={{ animationDelay: '0.3s' }}>
          <Image 
            src="/hero.png" 
            alt="Chess Traps App Mockup" 
            width={1200} 
            height={800} 
            priority
            className="w-full h-auto opacity-80"
          />
        </div>

        {/* Floating Stats */}
        <div className="floating-stats reveal" style={{ animationDelay: '0.5s' }}>
          <div className="stat-item">
            <span className="stat-value">1,000+</span>
            <span className="stat-label">Unique Traps</span>
          </div>
          <div className="stat-item">
            <span className="stat-value">24/7</span>
            <span className="stat-label">Engine Access</span>
          </div>
          <div className="stat-item">
            <span className="stat-value">50k+</span>
            <span className="stat-label">Active Users</span>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="grid-features">
        <div className="feature-card reveal" style={{ animationDelay: '0.1s' }}>
          <span className="icon">♟️</span>
          <h3 className="text-xl font-bold mb-4">Interactive Training</h3>
          <p className="text-[#888] leading-relaxed text-sm">
            Don't just memorize. Play through every trap with our interactive board that guides you through the winning moves.
          </p>
        </div>

        <div className="feature-card reveal" style={{ animationDelay: '0.2s' }}>
          <span className="icon">⚙️</span>
          <h3 className="text-xl font-bold mb-4">Stockfish Integration</h3>
          <p className="text-[#888] leading-relaxed text-sm">
            Analyze every position with the world's strongest chess engine. Understand exactly why a move works or fails.
          </p>
        </div>

        <div className="feature-card reveal" style={{ animationDelay: '0.3s' }}>
          <span className="icon">📈</span>
          <h3 className="text-xl font-bold mb-4">Personal Progress</h3>
          <p className="text-[#888] leading-relaxed text-sm">
            Track your mastery. Mark traps as learned and practice them periodically to ensure they stay in your repertoire.
          </p>
        </div>
      </section>

      {/* Final CTA */}
      <section className="py-32 text-center reveal">
        <h2 className="text-4xl font-bold mb-8">Ready to dominate?</h2>
        <Link href="https://play.google.com/store/apps/details?id=chesstraps.achrafcyber.com" className="btn-primary">
          Start Training Now
        </Link>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-8">
          <div className="logo opacity-30 text-sm">Chess Traps</div>
          <div className="flex gap-8 text-xs uppercase tracking-widest">
            <Link href="#" className="hover:text-white transition-colors">Privacy</Link>
            <Link href="#" className="hover:text-white transition-colors">Terms</Link>
            <Link href="#" className="hover:text-white transition-colors">Contact</Link>
          </div>
          <p className="text-[#444] text-xs">&copy; 2026 Achraf Cyber.</p>
        </div>
      </footer>
    </main>
  );
}

