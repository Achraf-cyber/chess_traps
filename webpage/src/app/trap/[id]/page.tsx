import { Metadata } from "next";

type Props = {
  params: Promise<{ id: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params;
  return {
    title: `Opening Trap #${id}`,
    description: `Discover the details of Chess Trap #${id}. Practice this sequence in the Chess Traps app with interactive analysis.`,
    openGraph: {
      title: `Master Chess Trap #${id}`,
      description: `Learn the winning sequence for Trap #${id} in our premium chess app.`,
      images: ["/hero.png"],
    },
  };
}

export default async function TrapPage({ params }: Props) {
  const { id } = await params;

  return (
    <main className="min-h-screen flex-center p-10 text-center relative overflow-hidden">
      <div className="hero-background" />
      
      <div className="glass-card max-w-lg w-full animate-fade-in">
        <div className="logo mb-8 px-4 py-1 border border-white/20 rounded-full w-fit mx-auto text-xs uppercase tracking-widest text-accent">
          CHESS TRAPS
        </div>
        
        <h1 className="heading-xl mb-6" style={{ fontSize: 'clamp(2rem, 8vw, 4rem)' }}>
          TRAP <span style={{ color: 'var(--accent)' }}>#{id}</span>
        </h1>
        
        <p className="text-subtle mb-10 leading-relaxed text-lg px-2">
          This classic opening trap is available for exploration in the <br/>
          <strong>Chess Traps</strong> application.
        </p>
        
        <div className="flex-col gap-4">
          <a href={`market://details?id=chesstraps.achrafcyber.com&url=https://chesstraps-web.vercel.app/trap/${id}`} 
             className="btn-primary w-full py-4 rounded-xl font-bold text-lg shadow-xl shadow-accent/10 hover:shadow-accent/30 flex-center">
            Open in App
          </a>
          
          <div className="mt-6 flex-col gap-2">
            <span className="text-faint text-sm">Don't have the app yet?</span>
            <a href="https://play.google.com/store/apps/details?id=chesstraps.achrafcyber.com" 
               className="text-subtle hover:text-accent transition-all duration-300 font-medium">
              Get it on Google Play
            </a>
          </div>
        </div>
      </div>

      <div className="absolute bottom-10 left-0 right-0 text-faint text-xs tracking-widest uppercase">
        Master your openings • Chess Traps 2026
      </div>
    </main>
  );
}
