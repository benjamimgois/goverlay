# Design: Purge MangoHud Legacy Containers and Dead Controls

## Context

See `proposal.md` for background and motivation.
In Lazarus LCL form streaming (`.lfm`), container controls (`TGroupBox`) define nested object hierarchies. When removing a container:
1. Active child components (checkboxes, color buttons, trackbars, comboboxes) must be lifted to the parent `TTabSheet` level.
2. Any `AnchorSide*.Control` properties pointing to the container or to dead sibling controls must be removed (`Anchors = []`).
3. Dead leaf components (`TImage`, orphaned `TCheckGroup`, dead labels) can be purged directly without reparenting.
4. Matching published fields in `overlayunit.pas` must be removed in tandem with the `.lfm` declarations.

## Goals / Non-Goals

**Goals:**
- Purge 6 obsolete GroupBoxes: `fpslimiterGroupBox`, `vsyncGroupBox`, `filtersGroupBox`, `fpsGroupBox` (Performance tab) and `loggingGroupBox`, `systemGroupBox` (Extras tab).
- Purge 6 decorative images: `fpstoggleImage`, `vulkanImage`, `openglImage`, `Image2`, `logtoggleImage`, `sysinfoImage`.
- Purge dead orphaned controls: `fpslimCheckGroup`, `filterRadioGroup`, `offsetSpinEdit`, `offsetLabel`, `fpslimLabel`.
- Reparent all active functional child controls directly under `performanceTabSheet` and `extrasTabSheet` with `Anchors = []` and `Visible = False`.
- Clean up obsolete `UnanchorControl` calls and dead field declarations in `overlayunit.pas` and `mangohud_ui.pas`.

**Non-Goals:**
- No changes to state-holding variables or checkboxes read/written during configuration load/save (`fpsCheckBox`, `vsyncComboBox`, `distroinfoCheckBox`, etc.).
- No changes to user-visible layout or modern card positioning logic in `mangohud_ui.pas`.
- No modification of non-MangoHud tabs (vkBasalt, OptiScaler, Tweaks) in this change.

## Decisions

### Decision 1: Per-Tab Batch Processing
- **Choice**: Batch the cleanup tab by tab:
  - Step 1: `performanceTabSheet` (`fpslimiterGroupBox`, `vsyncGroupBox`, `filtersGroupBox`, `fpsGroupBox` and associated leaf images/controls).
  - Step 2: `extrasTabSheet` (`loggingGroupBox`, `systemGroupBox` and associated leaf images/controls).
- **Rationale**: Keeps diffs isolated and verifiable. Each tab can be compiled and validated against focused GUI tests before moving to the next.

### Decision 2: Clear LFM Anchors and Default to Invisible
- **Choice**: On all reparented controls, strip explicit `AnchorSide*` references, set `Anchors = []`, and mark `Visible = False`.
- **Rationale**: Prevents LCL runtime streaming exceptions caused by dangling anchors to deleted containers. Modern card panels dynamically reparent and position these controls in `InitPerformanceTab` and `InitExtrasTab`.

## Risks / Trade-offs

- **[LCL Form Streaming Parse Error]** → Ensure all matching identifiers in `overlayunit.pas` published section and `overlayunit.lfm` are removed simultaneously. Verify with rapid compilation (`lazbuild tests/gui/gui_tests.lpi --ws=qt6`).
- **[Accidental State Loss]** → Verified: controls retaining user configuration (`fpsCheckBox`, `distroinfoCheckBox`, etc.) are reparented, not deleted. Test suites (`TestMangoHudPerformanceCompactToggles`, `TestMangoHudExtrasCompactToggles`) will catch any state desynchronization.
