# Design: Purge Legacy UI Dead Controls and Containers

## Context

GOverlay's interface is divided between legacy Lazarus Form definition (`overlayunit.lfm` / `overlayunit.pas`) and modern code-driven tab helpers (`mangohud_ui.pas`, `optiscaler_tab.pas`, `sidebar_nav.pas`). Over the course of refactoring, dozens of visual containers, preview shapes, and controls were hidden via runtime code rather than removed from the form file.

In Lazarus LCL streaming, components declared in `.lfm` are instantiated sequentially upon form creation. If a container (`TGroupBox` or `TPanel`) contains child controls, removing the container requires moving those child controls to the parent `TTabSheet` level in the `.lfm` hierarchy and clearing any anchor references pointing to the container.

## Goals / Non-Goals

**Goals:**
- Eliminate all 6 orphaned column shapes (`columShape` through `columShape5`) and clean up all 60+ repetitive visibility-setting lines in `overlayunit.pas` and `mangohud_ui.pas`.
- Remove dead sidebar shapes (`mangohudShape`, `vkbasaltShape`, `optiscalerShape`, `tweaksShape`) and clean up `sidebar_nav.pas`.
- Remove orphaned preview images (`vImage`, `hImage`, `squareImage`, `roundImage`, `hudtoggleImage`).
- Remove orphaned controls (`activegpuLabel`, `gpudescEdit`, `hudonoffComboBox`, `fpslimCheckGroup`, `fpslimLabel`, `offsetSpinEdit`, `offsetLabel`).
- Reparent active child controls in `.lfm` (e.g. `hudtitleEdit`, `offsetxSpinEdit`, `offsetySpinEdit`, `pcidevComboBox`, and metrics checkboxes) to their owning `TTabSheet` and remove obsolete `TGroupBox` containers (`orientationGroupBox`, `borderGroupBox`, `backgroundGroupBox`, `fontsGroupBox`, `positionGroupBox`, `columsGroupBox`, `gpuGroupBox`, `cpuGroupBox`, `goverlaybarPanel`).
- Remove obsolete `UnanchorControl` calls and dead field declarations in `overlayunit.pas`.

**Non-Goals:**
- No changes to state-holding controls (e.g. `verticalRadioButton`, `horizontalRadioButton`, `gpuavgloadCheckBox`, `cputempCheckBox`) linked by `TToggleSwitch` or read by `SaveMangoHudConfig` / `LoadMangoHudConfig`.
- No changes to user-visible layout, theme styling, or configuration files (`MangoHud.conf`, etc.).
- No changes to event handlers (`saveBitBtnClick`, `mangohudLabelClick`).

## Decisions

### Decision 1: Two-Phase Incremental Purge
- **Choice**: Separate the purge into two phases:
  - Phase 1: Pure leaf elements with zero children (shapes, images, orphaned labels/edits).
  - Phase 2: Containers (`TGroupBox`, `goverlaybarPanel`) requiring child reparenting in `.lfm`.
- **Rationale**: Isolates risk. Phase 1 cannot break child control trees or anchoring. Phase 2 can then be executed with verified child reparenting.

### Decision 2: Clear LFM Anchor Dependencies Before Container Removal
- **Choice**: In `overlayunit.lfm`, ensure no retained control has an `AnchorSideLeft.Control`, `AnchorSideTop.Control`, etc., pointing to a container slated for deletion.
- **Rationale**: If Lazarus encounters an anchor pointing to an unknown or deleted component during form streaming, it raises an exception (`EComponentError`). Anchors on reparented controls must point to the `TabSheet` or be omitted (since modern tab helpers apply `C.Anchors := [akLeft, akTop]` and clear anchors at runtime anyway).

## Risks / Trade-offs

- **[LCL Form Streaming Parse Error]** → Ensure all matching identifiers in `overlayunit.pas` published section and `overlayunit.lfm` are removed simultaneously. Verify compilation and startup with `make test-logic` and focused GUI tests.
- **[GUI Test Access to Removed Controls]** → Verified: `columShape*`, `*Shape` (sidebar), `*Image`, `*GroupBox` are not asserted in test suites (tests assert modern cards, toggles, and functional checkboxes).
