import { ImageResponse } from "next/og";

export const alt = "Trapster: learn chess opening traps";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default function Image() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          padding: 72,
          background: "#f7f2eb",
          color: "#1c1a17",
        }}
      >
        <div style={{ fontSize: 96 }}>Trapster</div>
        <div style={{ fontSize: 44, color: "#2f5d48", marginTop: 16 }}>
          Learn chess opening traps on a real board
        </div>
      </div>
    ),
    size,
  );
}
