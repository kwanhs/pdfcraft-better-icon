#!/usr/bin/env bash
# Regenerate every app icon from assets/app-icon/pdfcraft.svg (the master vector).
#
# Needs: resvg (brew install resvg / cargo install resvg) or cairosvg, and python3 (stdlib
# only, for the .ico and the .icns fallback). On macOS, iconutil writes the .icns; elsewhere
# a PNG-based .icns is packed in Python. The outputs are committed, so building and packaging
# never need these tools. After running it, update the sha256 values in ATTRIBUTION.toml, then
# `cargo xtask assets --write`.
#
#   packaging/icons.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$ROOT/assets/app-icon"
SVG="$DIR/pdfcraft.svg"
ID="ai.storyteller.pdfcraft"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export PATH="${HOME}/.local/bin:${PATH}"
if command -v resvg >/dev/null; then
  render() { resvg -w "$2" -h "$2" "$1" "$3" </dev/null; }
elif command -v cairosvg >/dev/null; then
  render() { cairosvg -f png -W "$2" -H "$2" "$1" -o "$3"; }
else
  echo "error: resvg or cairosvg not found (brew install resvg / pip install cairosvg)" >&2
  exit 1
fi

# The master already draws its own squircle with a transparent margin (32 px on a 512 tile),
# so macOS uses the same file scaled up instead of wrapping it again in Apple's 824/1024 grid.
MAC="$SVG"

# 1024 px PNG (also the runtime Dock icon on macOS, see apps/pdfcraft/src/main.rs).
render "$MAC" 1024 "$DIR/pdfcraft-1024.png"

# Linux hicolor theme (full bleed; hicolor/256x256 is also the runtime icon on Windows and Linux).
for s in 16 24 32 48 64 128 256 512; do
  mkdir -p "$DIR/hicolor/${s}x${s}/apps"
  render "$SVG" "$s" "$DIR/hicolor/${s}x${s}/apps/$ID.png"
done
mkdir -p "$DIR/hicolor/scalable/apps"
cp "$SVG" "$DIR/hicolor/scalable/apps/$ID.svg"

# Windows .ico: PNG-compressed entries, 16-256 px.
ICO_PNGS=()
for s in 16 20 24 32 40 48 64 128 256; do
  render "$SVG" "$s" "$TMP/ico-$s.png"
  ICO_PNGS+=("$TMP/ico-$s.png")
done
python3 - "$DIR/pdfcraft.ico" "${ICO_PNGS[@]}" <<'PY'
import struct, sys
out, pngs = sys.argv[1], sys.argv[2:]
blobs = [open(p, "rb").read() for p in pngs]
head = struct.pack("<HHH", 0, 1, len(blobs))
entries, data, offset = b"", b"", 6 + 16 * len(blobs)
for b in blobs:
    w, h = struct.unpack(">II", b[16:24])  # IHDR
    entries += struct.pack("<BBBBHHII", w % 256, h % 256, 0, 0, 1, 32, len(b), offset)
    data += b
    offset += len(b)
open(out, "wb").write(head + entries + data)
PY

# macOS .icns.
SET="$TMP/pdfcraft.iconset"
mkdir -p "$SET"
for s in 16 32 128 256 512; do
  render "$MAC" "$s" "$SET/icon_${s}x${s}.png"
  render "$MAC" $((s * 2)) "$SET/icon_${s}x${s}@2x.png"
done
if command -v iconutil >/dev/null; then
  iconutil -c icns -o "$DIR/pdfcraft.icns" "$SET"
else
  python3 - "$DIR/pdfcraft.icns" "$SET" <<'PY'
import os, struct, sys
out, iconset = sys.argv[1], sys.argv[2]
# PNG-based ICNS types. Sizes are the pixel size of the PNG.
types = {
    16: b"icp4",
    32: b"ic11",  # 16@2x
    64: b"ic12",  # 32@2x
    128: b"ic07",
    256: b"ic08",
    512: b"ic09",
    1024: b"ic10",
}
files = {
    16: "icon_16x16.png",
    32: "icon_16x16@2x.png",
    64: "icon_32x32@2x.png",
    128: "icon_128x128.png",
    256: "icon_128x128@2x.png",
    512: "icon_256x256@2x.png",
    1024: "icon_512x512@2x.png",
}
chunks = []
for size, name in files.items():
    data = open(os.path.join(iconset, name), "rb").read()
    payload = types[size] + struct.pack(">I", 8 + len(data)) + data
    chunks.append(payload)
body = b"".join(chunks)
open(out, "wb").write(b"icns" + struct.pack(">I", 8 + len(body)) + body)
PY
fi
echo "icons written to $DIR"
