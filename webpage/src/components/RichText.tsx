import Link from "next/link";
import React from "react";

const MARKUP = /(\*\*.+?\*\*|\[[^\]]+\]\([^)]+\))/;

/** Renders the `**bold**` and `[label](/path)` used in the guides. */
export default function RichText({ text }: { text: string }) {
  return text.split(MARKUP).map((part, i) => {
    if (part.startsWith("**")) {
      return (
        <strong key={i}>
          <RichText text={part.slice(2, -2)} />
        </strong>
      );
    }
    const link = part.match(/^\[([^\]]+)\]\(([^)]+)\)$/);
    if (link) {
      return (
        <Link key={i} href={link[2]}>
          {link[1]}
        </Link>
      );
    }
    return <React.Fragment key={i}>{part}</React.Fragment>;
  });
}
