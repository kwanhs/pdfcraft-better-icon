# PdfCraft app icon

<img src="pdfcraft-small.svg" alt="PdfCraft app icon: a document with a P on red" width="128">

**Mark:** a white page with a folded corner, a geometric **P**, two body-text rules and a red
accent bar, on a full-bleed red field.

**Style:** a flat document tile (not the Crafting Apps engraved-animal template). The P is a
rounded stem plus a D-shaped bowl, so it still reads at 16 px.

**Palette:**

| Colour | Hex | Used for |
|---|---|---|
| Field (top) | `#ff4a54` | upper full-bleed background |
| Field (bottom) | `#c21824` | lower full-bleed background |
| Letter (top) | `#d92230` | P |
| Letter (bottom) | `#9e121c` | P |
| Paper | `#ffffff` | the page |
| Fold | `#f7f8fa` → `#c4c9d2` | dog-ear |
| Rules | `#e3e6eb` | implied body text |
| Accent | `#e0313c` | underline on the page |

**Tile:** `viewBox="0 0 512 512"`, a rounded square with `rx=112` that clips everything. Windows and Linux
icons use the full-bleed tile. macOS icons put it on Apple's grid (an 824 px body centred on a transparent
1024 px canvas).

**Provenance:** contributor-original SVG, drawn for this repository (no third-party artwork, no Adobe
marks). Licence: [LICENSE.txt](LICENSE.txt) (`MIT OR Apache-2.0`, like the repo).

## Files

| File | What it is |
|---|---|
| `pdfcraft.svg` | the master vector; every PNG, `.ico` and `.icns` is rendered from it |
| `pdfcraft-small.svg` | the same mark, for places where size matters, such as this README |
| `pdfcraft-1024.png` | 1024 px on Apple's grid; also the runtime Dock icon on macOS |
| `pdfcraft.icns` | macOS icon (16–1024 px) |
| `pdfcraft.ico` | Windows icon (16–256 px), embedded in `pdfcraft.exe` by `apps/pdfcraft/build.rs` |
| `hicolor/<n>x<n>/apps/ai.storyteller.pdfcraft.png` | Linux hicolor theme, 16–512 px; the 256 px one is the runtime icon on Windows and Linux |
| `hicolor/scalable/apps/ai.storyteller.pdfcraft.svg` | Linux scalable icon (copy of the master) |

Where it shows: `apps/pdfcraft/src/main.rs` sets the window icon (Dock, taskbar, Alt-Tab, launcher) and the
Wayland app id `ai.storyteller.pdfcraft`; `packaging/linux/ai.storyteller.pdfcraft.desktop` names the
hicolor icon.

## Regenerate

```sh
packaging/icons.sh        # needs resvg or cairosvg, and python3; iconutil (macOS) for the .icns
cargo xtask assets        # then update the sha256 values in ATTRIBUTION.toml and run with --write
```
