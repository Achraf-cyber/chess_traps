import Link from "next/link";

export default function NotFound() {
  return (
    <main className="page narrow">
      <h1 className="heading-section">That square is empty</h1>
      <p className="lede">We couldn&apos;t find this page.</p>
      <p style={{ marginTop: "1rem" }}>
        <Link href="/learn">Read the guides</Link> or{" "}
        <Link href="/traps">browse every trap</Link>.
      </p>
    </main>
  );
}
