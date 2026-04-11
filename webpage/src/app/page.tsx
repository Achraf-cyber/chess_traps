import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <main className="container-wide flex-col items-center min-h-screen relative">
      <div className="hero-background" />

      {/* Navigation */}
      <nav className="nav container-wide">
        <div className="logo">CHESS TRAPS</div>
        <Link href="#download" className="btn-primary" style={{ padding: '0.75rem 1.5rem', borderRadius: '10px' }}>
          Get Started
        </Link>
      </nav>

      {/* Hero Section */}
      <section className="section-hero container-mid px-5">
        <h1 className="heading-xl mb-6 animate-fade-in" style={{ animationDelay: '0.1s' }}>
          MASTER THE <span style={{ color: 'var(--accent)' }}>ART</span><br/>
          OF THE TRAP
        </h1>
        <p className="paragraph-l text-subtle mb-12 animate-fade-in" style={{ animationDelay: '0.3s' }}>
          Stop losing to early blunders. Learn over 1,000 professional chess traps 
          with interactive practice and engine analysis.
        </p>
        
        <div className="flex-center gap-4 animate-fade-in" style={{ animationDelay: '0.5s' }}>
          <Link href="https://play.google.com/store/apps/details?id=chesstraps.achrafcyber.com" className="btn-primary">
            Download on Google Play
          </Link>
        </div>

        {/* Hero Image */}
        <div className="mt-20 animate-fade-in" style={{ animationDelay: '0.7s' }}>
          <div className="img-container">
            <Image 
              src="/hero.png" 
              alt="Chess Trap Hero" 
              width={1200} 
              height={800} 
              className="img-hero"
            />
            <div className="absolute inset-0 bg-gradient-hero" />
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section id="features" className="section-pad container-wide px-5 grid-3">
        <div className="glass-card">
          <div style={{ color: 'var(--accent)', fontSize: '2rem', marginBottom: '1rem' }}>01</div>
          <h3 className="text-2xl font-bold mb-4">1,000+ Traps</h3>
          <p className="text-subtle">From the Stafford Gambit to the fishing pole, we cover every known opening trap.</p>
        </div>
        <div className="glass-card">
          <div style={{ color: 'var(--accent)', fontSize: '2rem', marginBottom: '1rem' }}>02</div>
          <h3 className="text-2xl font-bold mb-4">Practice Mode</h3>
          <p className="text-subtle">Don't just watch. Play the moves yourself and get immediate feedback on your performance.</p>
        </div>
        <div className="glass-card">
          <div style={{ color: 'var(--accent)', fontSize: '2rem', marginBottom: '1rem' }}>03</div>
          <h3 className="text-2xl font-bold mb-4">Pro Engine</h3>
          <p className="text-subtle">Powered by the latest chess engine for real-time evaluation and best-move analysis.</p>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-20 text-center text-faint border-t border-white/5 w-full mt-auto">
        <p>&copy; 2026 Chess Traps by Achraf Cyber. All rights reserved.</p>
      </footer>
    </main>
  );
}
