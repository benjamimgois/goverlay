# Design: Eliminate Action Bar and Integrate Controls into Visual Cards

## Context

The Visual tab layout in `mangohud_ui.pas` is organized into:
- `FVisAppearanceCard` (left column: HUD Title, Typography, Canvas & Frame)
- `FVisLayoutCard` (right column: Screen Placement, Flow & Grid)
- `FVisActionBar` (bottom full-width panel: Hotkey, Compact HUD, Hide HUD, Active GPU)

Because `FVisActionBar` spans the full width of the tab at the bottom, its rightmost controls collide with GOverlay's global floating action dock (`[☰] [👁 Preview] [✓ Finish]`), which stays fixed in the bottom-right corner. See `proposal.md` for full motivation.

## Goals / Non-Goals

**Goals:**
- Eliminate `FVisActionBar` completely from `mangohud_ui.pas` and `Tgoverlayform`.
- Reparent `FhudcompactToggle` and `FVisCompactLbl` into `FVisCanvasSec` (Canvas & Frame).
- Create a dedicated `FVisSystemSec` sub-card ("Display & Hotkey") inside `FVisLayoutCard` to host `pcidevComboBox`, `FVisualCaptureBtn`, and `FhidehudToggle`.
- Expand both main cards to use the full vertical height of `visualTabSheet` (`ActiveCardsH := Max(520, TabH - 2 * MARGIN)`).
- Ensure zero overlap or collision with the global floating dock.
- Maintain 100% backward compatibility with configuration loading, auto-saving, and test assertions.

**Non-Goals:**
- Alter MangoHud configuration keys or semantics (`compact`, `no_display`, `pci_dev`, `toggle_hud`).
- Redesign the Metrics or Extras tabs.

## Decisions

### Decision 1: Relocate Compact HUD to Canvas & Frame (`FVisCanvasSec`)
- **Choice**: Place `FVisCompactLbl` and `FhudcompactToggle` on row 3 of `FVisCanvasSec` below Background Color / Corner Borders (row 1) and Opacity Slider (row 2).
- **Rationale**: Compact mode directly affects how the HUD frame renders (shortened metric labels and reduced cell padding). This places all HUD frame/canvas density settings together.
- **Alternative Considered**: Leaving it in a floating toolbar or putting it under Typography. Canvas is much more semantically aligned.

### Decision 2: Introduce `FVisSystemSec` Sub-Card in `FVisLayoutCard`
- **Choice**: Add a third sub-card in `FVisLayoutCard` titled `Display & Hotkey` (`FVisSystemSec`).
  - Row 1: `Active GPU:` label + `pcidevComboBox` dropdown.
  - Row 2: `HUD Toggle:` label + `FVisualCaptureBtn` hotkey capture button.
  - Row 3: `Hide HUD by default:` label + `FhidehudToggle` toggle switch.
- **Rationale**:
  - The left column (`FVisAppearanceCard`) has 3 sections: HUD Title header, Typography, and Canvas & Frame.
  - Adding `FVisSystemSec` to the right column (`FVisLayoutCard`) creates a perfect 3-section vertical symmetry:
    - Left: HUD Title + Typography + Canvas & Frame
    - Right: Screen Placement + Flow & Grid + Display & Hotkey
  - Pairing `HUD Toggle` with `Hide HUD by default` makes intuitive sense: users configure the key to show/hide the overlay directly alongside the setting specifying whether it starts hidden.
- **Alternative Considered**: Scattering controls into Screen Placement. That would overcrowd the monitor and offset coordinates.

### Decision 3: Expand Main Cards and Remove Bottom Action Bar
- **Choice**:
  - In `InitVisualTab`: Remove creation of `FVisActionBar`. Assign `FVisualCards[2] := nil`. Reparent the controls directly into `FVisCanvasSec` and `FVisSystemSec`.
  - In `ReflowVisualTab`: Reclaim the `ACTION_H` (46px) and `GAP` (8px). Set `ActiveCardsH := Max(520, TabH - 2 * MARGIN)`.
  - The main cards stretch cleanly to the bottom. Because the bottom-right corner is inside the card's inner margins and `FVisSystemSec` occupies the left/center of the column, the floating dock floats with ample clearance.

## Risks / Trade-offs

- **[Risk] Vertical compression on minimum window heights (e.g. 600px)**:
  - *Mitigation*: The sub-cards in `FVisLayoutCard` are proportioned cleanly (`FVisScreenSec` gets ~180px for the 120px monitor, `FVisFlowSec` gets ~105px, and `FVisSystemSec` gets ~115px). When `TabH` increases, they expand smoothly.
- **[Risk] GUI test failure expecting `FVisActionBar`**:
  - *Mitigation*: Update `TGoverlayGuiTests.TestMangoHudVisualCompactToggles` to assert `FVisSystemSec` and `FVisCanvasSec` instead of `FVisActionBar`.
