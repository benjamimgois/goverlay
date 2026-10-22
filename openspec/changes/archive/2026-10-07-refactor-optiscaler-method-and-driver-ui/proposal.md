# Proposal

## Why

In the OptiScaler tab, the "Method" selection card currently occupies only 50% of the horizontal space because the remaining 50% is taken by a large "GPU Driver" card with oversized vendor logos. Meanwhile, in the adjacent Frame Interpolation tab, "Method" spans 100% of the available width, creating visual inconsistency. Furthermore, GPU Driver selection is almost always auto-detected (`IsNvidiaModuleLoaded`) and rarely modified by users, making its prominent 50% placement disproportionate and visually cluttering. Moving GPU Driver into the "Options" card (under the "Main" sub-column) as a clean dropdown and expanding "Method" across the full width restores symmetry, aligns with Frame Interpolation, and maintains all functional capabilities without visual clutter.

## What Changes

- Expand the OptiScaler "Method" card (`FOsUpscalerCard`) to occupy 100% of the available horizontal width (`CW`), evenly distributing the three options ("None", "OptiScaler", "DLSS Enabler") with balanced spacing.
- Hide/deprecate the top-level standalone "GPU Driver" card (`FOsGpuCard`), removing the large vendor graphics from the top row.
- Add a compact "GPU Driver" `TComboBox` (and associated label) inside the "Main" sub-column of the "Options" card (`FOsMainSec`), allowing users to toggle between Mesa (AMD/Intel) and NVIDIA (with auto-detection indication).
- Synchronize the new dropdown with existing radio button state and backend routines (`SaveOptiScalerDriverPreference`, reflex toggles, and spoofing options) to preserve complete functional parity and test compatibility.

## Capabilities

### New Capabilities
*(None)*

### Modified Capabilities
- `optiscaler-method-selector`: Update Method card layout requirements so it spans the entire horizontal width of the tab with three evenly distributed slots, rather than sharing the top row with a separate GPU Driver card.
- `optiscaler-options-layout`: Add GPU Driver selection to the "Main" options column while maintaining the strict height constraints that prevent vertical scrolling on standard window heights.

## Impact

- **UI Code**: `optiscaler_tab.pas` (`ReflowOptiScalerTabNew`, `FOsUpscalerCard`, `FOsGpuCard`, `FOsMainSec`), `overlayunit.pas` (`gpudriverComboBox` setup and event handling).
- **Backend / Config**: `themeunit.pas` (`SaveOptiScalerDriverPreference`, `LoadOptiScalerDriverPreference`) and `overlayunit.pas` (driver change handlers). Existing logic remains intact.
- **Tests**: `tests/gui/gui_test_cases.pas` (verifies Method card layout, driver switching, and dependent control states).
