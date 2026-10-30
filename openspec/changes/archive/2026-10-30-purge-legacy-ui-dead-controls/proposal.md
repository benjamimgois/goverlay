# Proposal: Purge Legacy UI Dead Controls and Containers

## Why

GOverlay has successfully transitioned to a modern, code-driven modular interface with dedicated card panels, custom toggle switches, a vector monitor layout, and an animated floating action dock. However, the underlying Lazarus form definition (`overlayunit.lfm`) and form unit (`overlayunit.pas`) still instantiate hundreds of legacy visual elements—obsolete shapes, decorative preview bitmaps, old group box containers, and orphaned controls—that are never rendered to the user.

These zombie components bloat the `.lfm` streaming resource, add unnecessary object allocation at startup, and pollute the Pascal codebase with dozens of boilerplate `Visible := False` and `UnanchorControl` lines. Purging these unused elements will simplify the code, reduce form complexity, and streamline future UI development.

## What Changes

- **Purge Obsolete Shapes (Grupo A)**:
  - Remove `columShape`, `columShape1`, `columShape2`, `columShape3`, `columShape4`, and `columShape5` from `overlayunit.lfm` and `overlayunit.pas`.
  - Eliminate over 60 repetitive `columShape*.Visible := False` lines across `overlayunit.pas` and `mangohud_ui.pas`.
  - Remove legacy sidebar shapes (`mangohudShape`, `vkbasaltShape`, `optiscalerShape`, `tweaksShape`) superseded by `sidebar_nav.pas`.

- **Purge Orphaned Images and Labels (Grupo A)**:
  - Remove legacy preview images (`vImage`, `hImage`, `squareImage`, `roundImage`, `hudtoggleImage`).
  - Remove orphaned labels, edits, and combos that are no longer referenced by active UI or configs (`activegpuLabel`, `gpudescEdit`, `hudonoffComboBox`).
  - Remove orphaned performance controls (`fpslimCheckGroup`, `fpslimLabel`, `offsetSpinEdit`, `offsetLabel`).

- **Reparent and Remove Obsolete Containers (Grupo B)**:
  - Reparent valid active controls (such as `hudtitleEdit`, `offsetxSpinEdit`, `offsetySpinEdit`, `pcidevComboBox`, and metric checkboxes) in `overlayunit.lfm` directly under their owning `TTabSheet` components (`visualTabSheet`, `metricsTabSheet`, `performanceTabSheet`).
  - Remove obsolete `TGroupBox` containers from `overlayunit.lfm` and `overlayunit.pas`:
    - Visual: `orientationGroupBox`, `borderGroupBox`, `backgroundGroupBox`, `fontsGroupBox`, `positionGroupBox`, `columsGroupBox`.
    - Metrics: `gpuGroupBox`, `cpuGroupBox`.
  - Remove legacy bottom bar container `goverlaybarPanel` and redundant `UnanchorControl` calls.

- **Preserve Functional State and Serialization (Non-goals)**:
  - Do NOT modify or remove controls that hold serialization state (e.g., metric checkboxes like `gpuavgloadCheckBox`, `cputempCheckBox` linked via `TToggleSwitch`, or orientation radio buttons).
  - Do NOT alter any configuration file reading or writing schemas (`MangoHud.conf`, `vkBasalt.conf`, `OptiScaler.ini`).

## Capabilities

### New Capabilities
None.

### Modified Capabilities
None. This is an internal code refactoring and dead component cleanup that maintains 100% backward compatibility with existing configuration schemas and user settings. The change sets `skip_specs: true`.

## Impact

- `overlayunit.lfm`: Substantial line count reduction and cleaner object hierarchy.
- `overlayunit.pas`: Removal of zombie component field declarations and initialization boilerplate.
- `mangohud_ui.pas`: Removal of obsolete container hiding and unanchoring logic.
- `sidebar_nav.pas`: Removal of legacy shape visibility suppression.
- Test suites: Unchanged behavior across `make test-logic` and focused GUI integration tests.
