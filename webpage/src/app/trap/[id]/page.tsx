export default async function TrapPage({ params }: { params: { id: string } }) {
  const { id } = await params;

  return (
    <main className="min-h-screen flex-center p-10 text-center relative overflow-hidden">
      <div className="hero-background" />
      
      <div className="glass-card max-w-lg w-full animate-fade-in">
        <div className="logo mb-8">CHESS TRAPS</div>
        
        <h1 className="text-4xl font-bold mb-6">Opening Trap #{id}</h1>
        <p className="text-subtle mb-10">
          This chess trap is available in the Chess Traps app. Download now to 
          view the moves and practice against the engine.
        </p>
        
        <div className="flex-col gap-4">
          <a href={`market://details?id=chesstraps.achrafcyber.com&url=https://chesstraps-web.vercel.app/trap/${id}`} 
             className="btn-primary w-full">
            Open in App
          </a>
          
          <a href="https://play.google.com/store/apps/details?id=chesstraps.achrafcyber.com" 
             className="text-muted hover:text-white transition-colors duration-300">
            Download on Google Play
          </a>
        </div>
      </div>

      <div className="mt-10 text-faint text-sm">
        Click "Open in App" to view this trap directly.
      </div>
    </main>
  );
}
