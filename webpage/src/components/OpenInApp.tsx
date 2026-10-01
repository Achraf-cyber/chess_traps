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
export default function OpenInApp({
  trapId,
  path = `/trap/${trapId}`,
  openLabel = "▶ Open in Trapster",
  storeLabel = "Get it on Google Play",
}: {
  trapId?: number;
  /** App-link path to open, e.g. `/club/ECHECS-LYON`. Defaults to the trap. */
  path?: string;
  openLabel?: string;
  storeLabel?: string;
}) {
  const [href, setHref] = useState(PLAY_URL);

  useEffect(() => {
    const isAndroid = /android/i.test(navigator.userAgent);
    if (isAndroid) {
      const fallback = encodeURIComponent(PLAY_URL);
      setHref(
        `intent://${HOST}${path}#Intent;scheme=https;package=${PACKAGE};S.browser_fallback_url=${fallback};end`,
      );
    }
  }, [path]);

  return (
    <div className="cta-row" style={{ justifyContent: "flex-start" }}>
      <a href={href} className="btn-primary">
        {openLabel}
      </a>
      <a href={PLAY_URL} className="btn-outline">
        {storeLabel}
      </a>
    </div>
  );
}
