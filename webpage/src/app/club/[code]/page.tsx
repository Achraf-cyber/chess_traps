import { Metadata } from "next";
import { notFound } from "next/navigation";
import OpenInApp from "@/components/OpenInApp";
import { APP_NAME } from "@/lib/traps";

type Props = { params: Promise<{ code: string }> };

// Club codes are set by hand in Firebase Remote Config; this only filters out
// junk so arbitrary text never gets rendered as a "code".
const CODE_PATTERN = /^[A-Za-z0-9_-]{2,32}$/;

function readCode(raw: string): string | null {
  const code = decodeURIComponent(raw).trim().toUpperCase();
  return CODE_PATTERN.test(code) ? code : null;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { code: raw } = await params;
  const code = readCode(raw);
  return {
    title: code ? `Join ${code} on ${APP_NAME}` : `${APP_NAME} club`,
    description: `Your chess club uses ${APP_NAME} to learn opening traps. Install the app and join with code ${code ?? ""}.`,
    // One page per club code: nothing here is worth indexing.
    robots: { index: false, follow: false },
  };
}

/**
 * Where a club's invite link lands when the app is not installed. With the
 * app installed, Android opens the link in the app directly and it joins the
 * club; this page only exists for everyone else.
 *
 * The app can't yet read the code across a Play Store install, so the page
 * shows it large enough to copy into Profile → Join a club.
 *
 * The pilot clubs are French, so the copy is in French with English below.
 */
export default async function ClubPage({ params }: Props) {
  const { code: raw } = await params;
  const code = readCode(raw);
  if (!code) notFound();

  return (
    <main className="trap-page">
      <span className="trap-tag">Club</span>
      <h1 className="trap-title">Rejoignez votre club sur {APP_NAME}</h1>
      <p className="trap-sub">
        Votre club d&apos;échecs vous invite à apprendre les pièges
        d&apos;ouverture avec {APP_NAME}. Installez l&apos;application, puis
        ouvrez <strong>Profil → Rejoindre un club</strong> et saisissez ce code :
      </p>

      <p
        className="trap-title"
        style={{
          fontFamily: "monospace",
          letterSpacing: "0.08em",
          userSelect: "all",
          margin: "1.5rem 0 2rem",
        }}
      >
        {code}
      </p>

      <OpenInApp
        path={`/club/${encodeURIComponent(code)}`}
        openLabel="▶ Ouvrir dans Trapster"
        storeLabel="Télécharger sur Google Play"
      />

      <section className="trap-section">
        <h2>English</h2>
        <p className="trap-sub">
          Your chess club invites you to learn opening traps with {APP_NAME}.
          Install the app, open <strong>Profile → Join a club</strong>, and
          enter the code <strong>{code}</strong>. If the app is already
          installed, the button above joins the club for you.
        </p>
      </section>
    </main>
  );
}
