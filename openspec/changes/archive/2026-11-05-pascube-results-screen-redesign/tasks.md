# Tasks: PasCube Results Screen Readability and Visual Modernization

## 1. Cinematic Backdrop Scrim and Opaque Card Canvas

- [x] 1.1 In `pascube_src/src/UnitPasCubeScreen.pas` (`DrawResultsOverlay`), add a full-screen translucent backdrop scrim (`1920x1080`, `alpha = 0.75` in deep navy `#080c14`) prior to drawing any cards, and verify background scene luminance is appropriately subdued.
- [x] 1.2 Update all card backgrounds (`Hardware Comparison`, `Main Score`, CPU Single/Multi, GPU Raster, Ray Tracing, `Live Telemetry`, `Score Trend`) to use 100% solid opaque fill in Goverlay navy (`#131a28`, `alpha = 1.0`) with crisp slate borders (`#2e3d58`, 1.5px), and verify 3D geometry no longer bleeds into card interiors.

## 2. Hero Card and Metric Visual Hierarchy

- [x] 2.1 Update the `Main Score` card with a 2px Goverlay Cyan border (`#30BEF0`) and integrate the performance tier classification pill (`tierName`, e.g. `TIER: HIGH-END GAMER`) computed via `GetScoreTier` alongside the title.
- [x] 2.2 Standardize card header typography across all sub-score cards to high-contrast slate-200 (`#cbd5e1`), and add a thematic magenta/violet accent badge to the Ray Tracing Score card.
- [x] 2.3 Enhance the `Current System` entry in `Hardware Comparison` with an illuminated container card, dual progress bars (Raster Cyan + RT Magenta), and verify specifications text remains sharp and legible.

## 3. Build & Visual Verification

- [x] 3.1 Compile PasCube via `lazbuild` in `pascube_src/` and verify compilation succeeds with zero errors.
- [x] 3.2 Safely copy the newly built binary to `./pascube` and verify that the results overlay displays with high contrast, complete opacity, and no visual bleed from the rotating 3D cube.
