"use client";

import { useEffect, useState } from "react";

const PACKAGE = "chesstraps.achrafcyber.com";
const HOST = "chess-traps.vercel.app";
const PLAY_URL = `https://play.google.com/store/apps/details?id=${PACKAGE}`;

/**
 * "Open in app" button that deep-links into Trapster if it's installed, and
 * falls back to the Play Store otherwise.
 *
 * On Android we use an `intent://` URL with a built-in `browser_fallback_url`,
 * which is the only reliable way to "open app OR go to store" in one tap.
 * Everywhere else (iOS with no app yet, desktop) we simply point at the store.
 */
export default function OpenInApp({ trapId }: { trapId: number }) {
  const [href, setHref] = useState(PLAY_URL);

  useEffect(() => {
    const isAndroid = /android/i.test(navigator.userAgent);
    if (isAndroid) {
      const fallback = encodeURIComponent(PLAY_URL);
      setHref(
        `intent://${HOST}/trap/${trapId}#Intent;scheme=https;package=${PACKAGE};S.browser_fallback_url=${fallback};end`,
      );
    }
  }, [trapId]);

  return (
    <div className="cta-row" style={{ justifyContent: "flex-start" }}>
      <a href={href} className="btn-primary">
        ▶ Open in Trapster
      </a>
      <a href={PLAY_URL} className="btn-outline">
        Get it on Google Play
      </a>
    </div>
  );
}
