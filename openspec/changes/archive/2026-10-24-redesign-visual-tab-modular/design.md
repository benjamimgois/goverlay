# Design

## Context

The Visual tab in GOverlay is managed in `mangohud_ui.pas` by `InitVisualTab`, `ReflowVisualTab`, and `UpdateVisualCardTheme`. Controls are reparented onto `visualTabSheet` using `Place()` and `TPanel` containers. See `proposal.md` for motivation and scope.

## Goals / Non-Goals

**Goals:**
- Restructure `visualTabSheet` into a balanced two-column modular layout:
  - `FVisAppearanceCard` (Left column: Appearance & Typography)
  - `FVisLayoutCard` (Right column: Position & Layout)
  - `FVisActionBar` (Bottom full-width: Key capture, display toggles, active GPU)
- Subdivide each column card into elevated sub-panels (`SubCardPaint`) with clean headers and consistent vertical baselines.
- Reparent `hudtitleEdit` into `FVisAppearanceCard` and `pcidevComboBox` into `FVisActionBar`, eliminating detached floating controls.
- Replace legacy radio buttons and images for Orientation and Border styles with styled segmented dual-pills (`TBitBtn` with `StyleBitBtnTheme`).
- Relocate `offsetxSpinEdit` and `offsetySpinEdit` outside `Image1` into dedicated, labeled controls below the monitor.
- Implement responsive sizing in `ReflowVisualTab` that expands cards smoothly on window resize without clipping.

**Non-Goals:**
- Altering MangoHud config serialization keys (`legacy_layout`, `round_corners`, `hud_compact`, `position`, `offset_x`, `offset_y`, `font_size`, `font_color`, etc.).
- Modifying underlying configuration load/save procedures in `overlay_config.pas`.

## Decisions

### 1. Two-Column Modular Layout with Action Bar
- **Choice:** Partition the tab into two equal-width main cards (`FVisAppearanceCard` and `FVisLayoutCard`) filling the upper vertical space, anchored by a compact full-width action bar (`FVisActionBar`) at the bottom.
- **Rationale:** Establishes semantic symmetry between visual styling (left) and spatial geometry (right), matching the design language of the Metrics and Extras tabs.
- **Alternative Considered:** A 3-module stacked horizontal layout was explored (Option B), but it produced overly wide, sparse rows on widescreen displays.

### 2. Segmented Dual-Pills for Binary Visual Options
- **Choice:** Create segmented dual-pills for Orientation (`[ ↕ Vertical | ↔ Horizontal ]`) and Borders (`[ Retos | Redondos ]` / `[ Square | Round ]`), styled with `StyleBitBtnTheme` and cyan active highlight.
- **Rationale:** Radio buttons with detached icons consume excessive space and feel dated; segmented pills provide immediate tactile feedback and high contrast.

### 3. Clear Separation of Monitor Graphic and Coordinates
- **Choice:** Cleanly position `offsetxSpinEdit` and `offsetySpinEdit` below the monitor preview in side-by-side labeled containers, keeping the monitor canvas strictly reserved for the 9 position anchor targets.
- **Rationale:** Eliminates the visual clutter of having input boxes awkwardly floating on top of the monitor graphic between radio buttons.

### 4. Integration of HUD Title and Active GPU
- **Choice:** Place `hudtitleEdit` inside `FVisAppearanceCard` above the typography module, and place `pcidevComboBox` inside `FVisActionBar` beside the quick toggles.
- **Rationale:** Eliminates the orphaned top input and the disconnected bottom GPU bar, unifying all tab controls within the card hierarchy.

## Risks / Trade-offs

- **[Risk] Narrow viewport width contention:** Two columns could become tight on small resolutions (e.g. 1024x768).
  - **Mitigation:** Calculate column widths dynamically in `ReflowVisualTab` (`SecW := (CW - GAP) div 2`), enforce min-width floors, and ensure seamless vertical scroll container integration if form client height is constrained.
- **[Risk] Syncing segmented pills with presets:** When user switches presets, pills must visually reflect the active state.
  - **Mitigation:** Implement explicit sync helpers (`SyncVisualPills`) called in `visualTabSheetShow` and preset update callbacks, ensuring the active button is highlighted in cyan.
