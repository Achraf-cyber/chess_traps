import Image from "next/image";
import Link from "next/link";
import ChessDiagram from "@/components/ChessDiagram";
import { getArticles } from "@/lib/articles";
import { PLAY_URL, popularTraps, TRAP_TOTAL } from "@/lib/traps";

export default function Home() {
  const guides = getArticles().filter((a) => a.trapId !== null).slice(0, 6);

  return (
    <main className="page">
      <section className="hero">
        <div>
          <h1>Stop falling for opening traps. Start setting them.</h1>
          <p className="lede">
            Trapster teaches {TRAP_TOTAL}{" "}chess traps on a real board, from
            Scholar&apos;s Mate to the Stafford Gambit. Practise each one from
            memory, learn how to avoid it, and test your ideas against
            Stockfish.
          </p>
          <div className="cta-row">
            <a href={PLAY_URL} className="btn-primary">
              Get it on Google Play
            </a>
            <Link href="/learn" className="btn-outline">
              Read the guides
            </Link>
          </div>
          <p className="hero-note">
            Free on Android, with ads. In English, French, Spanish and Arabic.
          </p>
        </div>
        <div className="hero-shots">
          <div className="shot">
            <Image
              src="/screens/home.webp"
              alt="Trapster home screen showing the trap of the day on a chess board"
              width={720}
              height={1540}
              sizes="(min-width: 52rem) 15rem, 45vw"
              priority
            />
          </div>
          <div className="shot">
            <Image
              src="/screens/trap.webp"
              alt="A trap in Trapster, with Stockfish arrows and the move list"
              width={720}
              height={1540}
              sizes="(min-width: 52rem) 15rem, 45vw"
              priority
            />
          </div>
        </div>
      </section>

      <section className="section">
        <div className="feature-list">
          <div>
            <h3>Practise from memory</h3>
            <p>
              Play the trapper&apos;s moves yourself. A wrong move is refused,
              and a second one earns a hint arrow, so the line sticks.
            </p>
          </div>
          <div>
            <h3>Learn the way out</h3>
            <p>
              Avoid mode puts you on the receiving end and asks you to find the
              move that escapes. Knowing a trap only helps if you can spot it
              coming.
            </p>
          </div>
          <div>
            <h3>Check it with Stockfish</h3>
            <p>
              Stockfish 19 runs on your phone. See the evaluation, the best
              lines and mates as they appear, then play a game against it at
              the strength you choose.
            </p>
          </div>
        </div>
      </section>

      <section className="section split">
        <div>
          <h2 className="heading-section">Find the trap in your opening</h2>
          <p>
            Play your moves on the search board and the list narrows to the
            traps still possible from that position, along with the moves that
            come next. Or search by name.
          </p>
          <p>
            It&apos;s the quickest way to see what you can spring on your
            opponents, and what they can spring on you.
          </p>
          <Link href="/traps" className="btn-outline">
            Browse every trap
          </Link>
        </div>
        <div className="shot">
          <Image
            src="/screens/search.webp"
            alt="Trapster search: a chess board above a list of matching traps"
            width={720}
            height={1540}
            sizes="17rem"
          />
        </div>
      </section>

      <section className="section">
        <h2>Popular guides</h2>
        <div className="guide-list">
          {guides.map((a) => (
            <Link key={a.slug} href={`/learn/${a.slug}`} className="guide-card">
              <ChessDiagram
                fen={a.boardFen}
                orientation={a.orientation}
                alt={`Position from the ${a.headline}`}
              />
              <h3>{a.headline}</h3>
            </Link>
          ))}
        </div>
        <p style={{ marginTop: "1.5rem" }}>
          <Link href="/learn/best-chess-traps">
            10 chess traps every player should know
          </Link>
        </p>
      </section>

      <section className="section">
        <h2>More chess traps</h2>
        <div className="card-grid">
          {popularTraps(12).map((t) => (
            <Link key={t.id} href={`/trap/${t.id}`} className="card-link">
              <span className="card-title">{t.trapName}</span>
              <span className="card-meta">{t.cleanMoves}</span>
            </Link>
          ))}
        </div>
      </section>

      <section className="closing">
        <h2>Your next game could end in seven moves</h2>
        <p>Make sure it&apos;s your opponent who didn&apos;t see it coming.</p>
        <a href={PLAY_URL} className="btn-primary">
          Get Trapster for free
        </a>
      </section>
    </main>
  );
}
