# Proposal: PasCube Results Screen Readability and Visual Modernization

## Why

In PasCube's post-benchmark results screen (`bpResults`), dashboard panels and metric cards are rendered with semi-transparent backgrounds (`alpha 0.92 ~ 0.95`). As a consequence, the rotating 3D benchmark cube with its bright neon edges and studio floor reflections shines directly through the cards, cutting across text labels, numbers, the Score Trend graph, and the Hardware Comparison list. This transparency bleed degrades legibility and makes the interface appear murky and unpolished.

Modernizing the results screen with a cinematic backdrop scrim, 100% opaque Goverlay-styled cards, an elevated Hero Score card featuring an integrated performance Tier Badge, and thematic accents for Ray Tracing and the current system entry significantly improves contrast, readability, and visual hierarchy.

## What Changes

- **Cinematic Backdrop Scrim**: Render a full-screen dark translucent backdrop (`alpha = 0.75` in deep navy `#080c14`) over the 3D viewport during the results phase to softly subdue background geometry and floor glare while preserving 3D scene depth.
- **100% Opaque Dashboard Cards**: Update all results cards (`Main Score`, CPU/GPU 2x2 grid, `Live Telemetry`, `Score Trend`, and `Hardware Comparison`) from translucent fills to 100% solid Goverlay navy (`#131a28`) with clean 1.5px slate borders (`#2e3d58`), completely preventing internal 3D bleed-through.
- **Hero Main Score with Integrated Tier Badge**: Elevate the `Main Score` card with a luminous Goverlay Cyan border (`#30BEF0`) and surface the calibrated performance tier classification badge (e.g., `TIER: HIGH-END GAMER PC`, `TIER: MID-RANGE GAMER PC`, etc., computed by `GetScoreTier`) directly adjacent to the score label.
- **Thematic Ray Tracing and System Accents**:
  - Add a dedicated magenta/violet accent badge to the Ray Tracing Score card, harmonizing with the 3D cube's RT light signature.
  - Enhance the `Current System` entry in the `Hardware Comparison` leaderboard with an illuminated container card, clear dual progress bars (Raster Cyan + RT Magenta), and animated ping indicator.
- **High-Contrast Metrics & Typography**: Standardize metric titles to crisp high-contrast slate-200 (`#cbd5e1`), replacing low-contrast dim blue text.

## Capabilities

### Modified Capabilities
- `pascube-ui-presentation`: Update requirements for the results overlay to mandate full-screen backdrop scrim dimming, 100% opaque card rendering, integrated performance tier badges in the hero card, and thematic ray tracing visual accents.

## Impact

- **Affected Code**: `pascube_src/src/UnitPasCubeScreen.pas` (`DrawResultsOverlay`, `DrawStyledCard`, hardware comparison rendering).
- **Compilation**: Built via `lazbuild` with Qt6 widgetset (`pascube_src/pascube.lpi`).
- **Dependencies**: No external library additions; leverages existing `TpvTextOverlay` Vulkan canvas and SDF primitives.
