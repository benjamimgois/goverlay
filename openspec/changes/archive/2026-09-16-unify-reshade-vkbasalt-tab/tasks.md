## 1. Asset Generation & Icon Integration

- [x] 1.1 Generate `assets/icons/method_reshade.png` combining the official circular RGB ring and "ReShade" text. Verify image dimensions and alpha transparency.
- [x] 1.2 Generate `assets/icons/method_vkbasalt.png` with rendered typography for "vkBasalt". Verify image dimensions and alpha transparency.

## 2. Method Card Construction & Dynamic View Toggling

- [x] 2.1 In `reshade_tab.pas`, construct `FMethodCard` with radio buttons and clickable logos for None, ReShade, and vkBasalt, implementing 35% opacity dimming for unselected options via `CreateDimmedPng`. Verify compilation with `lazbuild goverlay.lpi`.
- [x] 2.2 In `reshade_tab.pas`, implement dynamic view toggling: show ReShade cards when ReShade is selected; show vkBasalt cards when vkBasalt is selected; show disabled notice when None is selected. Verify switching between options without overlapping.
- [x] 2.3 In `reshade_tab.pas`, remove the redundant "Enable ReShade" checkbox (`FEnableCheckBox`) from `FConfigCard` and reflow controls. Verify layout compactness.

## 3. Software Status Card Expansion & Persistence

- [x] 3.1 In `reshade_tab.pas`, expand `FStatusCard` to remain persistently visible at the base of the tab across all methods and display dual status indicators for ReShade and vkBasalt (via `GetVkBasaltVersion`). Verify visual balance.
- [x] 3.2 In `reshade_tab.pas`, update `LoadConfig` and `SaveConfig` to enforce mutual exclusion between `GOVERLAY_RESHADE` and `GOVERLAY_VKBASALT` in `bgmod.conf`. Verify saved settings persist across reload.

## 4. Navigation & Tab Bar Visibility

- [x] 4.1 In `overlayunit.pas`, set `vkbasaltTabSheet.TabVisible := False` when opening Post processing, leaving `[ ReShade ] [ vkSumi ]` visible in the tab bar. Verify tab switching behavior.

## 5. Testing & Verification

- [x] 5.1 Update GUI test assertions in `tests/gui/gui_test_cases.pas` to test Method card radio buttons and logos, hidden `vkbasaltTabSheet`, dynamic view toggling, and dual Software status indicators.
- [x] 5.2 Execute `make test` to verify that all test suites pass with 0 errors and 0 failures.
- [x] 5.3 Run `openspec validate unify-reshade-vkbasalt-tab` and verify zero errors.
