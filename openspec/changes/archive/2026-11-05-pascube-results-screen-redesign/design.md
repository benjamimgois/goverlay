# Design: PasCube Results Screen Readability and Visual Modernization

## Context

PasCube draws its results interface during `bpResults` in `DrawResultsOverlay` using Vulkan 2D SDF rendering provided by `TpvTextOverlay`. Currently, all card rectangles are added with `alpha 0.92` to `0.95`, causing the rotating 3D PasCube model and its vibrant neon edges and reflective floor to bleed into cards, impairing text contrast.

See `proposal.md` for background and problem motivation.

## Goals / Non-Goals

**Goals:**
- Eliminate visual interference from the 3D scene onto text, graphs, and hardware comparison lists.
- Establish visual hierarchy by elevating `Main Score` as the primary "Hero Card" with Goverlay Cyan accent and an integrated performance tier badge.
- Enhance contrast of all metric card titles and sub-scores.
- Highlight the `Current System` entry in the `Hardware Comparison` leaderboard.
- Keep the 3D scene running softly in the background for depth, rather than freezing or blacking it out completely.

**Non-Goals:**
- Altering the benchmark scoring formulas, hardware reference scores, or submission APIs.
- Redesigning the bottom action buttons (already modernized in the previous change).
- Modifying the idle menu (`bpIdleMenu`) or running phase overlay.

## Decisions

### 1. Full-Screen Backdrop Scrim (`alpha = 0.75`)
- **Choice**: Render a 1920x1080 translucent scrim (`8.0/255.0, 12.0/255.0, 20.0/255.0, 0.75`) as the first draw call in `DrawResultsOverlay`.
- **Rationale**: Gently attenuates the 3D cube and floor lighting so they provide an atmospheric, living backdrop through the margins and gaps between columns, while reducing peak background luminance by ~75%.
- **Alternative considered**: Stopping the 3D render loop or rendering a pitch black background. Rejected because it destroys the cinematic, real-time feel of the PasCube engine.

### 2. 100% Solid Card Fill (`alpha = 1.0`) with Reinforced Slate Borders
- **Choice**: Render all card backgrounds with `alpha = 1.0` using deep Goverlay navy (`19.0/255.0, 26.0/255.0, 40.0/255.0`) and 1.5px borders in slate (`46.0/255.0, 61.0/255.0, 88.0/255.0, 1.0`).
- **Rationale**: 100% opaque fills completely prevent bright 3D geometry from bleeding into text and numbers.

### 3. Hero Main Score Card with Integrated Performance Tier Badge
- **Choice**:
  - Main Score card receives a 2px Goverlay Cyan border (`#30BEF0`).
  - Compute performance tier via `GetScoreTier(fCurrentResult.TotalScore, tierName, tR, tG, tB)` and render a styled badge (e.g. `TIER: HIGH-END GAMER`) directly beside the `Main Score` header text.
- **Rationale**: Immediately signals hardware class and creates a strong visual focal point.

### 4. High-Contrast Typography
- **Choice**: Change card title text from dim blue (`96, 165, 250` at scale 0.85-1.0) to high-contrast crisp slate-200 (`203/255.0, 213/255.0, 225/255.0`).
- **Rationale**: Greatly increases readability and matches Goverlay's dark UI guidelines.

### 5. Thematic Ray Tracing and Hardware Comparison Highlights
- **Choice**:
  - Add a subtle RT badge / accent in magenta/violet (`217, 70, 239`) to the Ray Tracing Score card.
  - Render a prominent highlight box around the `Current System` entry in the `Hardware Comparison` leaderboard, accompanied by the animated beacon dot.

## Risks / Trade-offs

- **[Performance impact of full-screen scrim]** → Scrim is a single 2D quad (1 `AddBox` call) in the SDF text overlay pipeline; impact is virtually 0ms.
- **[Layout overflow on small displays]** → TextOverlay uses virtual coordinates (1920x1080) automatically scaled to the swapchain window dimensions.
