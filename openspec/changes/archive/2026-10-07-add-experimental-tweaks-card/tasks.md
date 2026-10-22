# Tasks

## 1. Data Model & Checkbox Definitions

- [x] 1.1 Add `TWEAK_CAT_EXPERIMENTAL = 4` to categories, adjust custom and args category numbers, and update `TweakCategoryName` in `tweaks_md3.pas`. Verify compilation.
- [x] 1.2 Declare `FProtonVkd3dHeapCheckBox`, `FNvidiaDlssRROverrideCheckBox`, and `FVkd3dRtasSizeMultCheckBox` on `Tgoverlayform` in `overlayunit.pas`, and instantiate them in `InitTweaksMD3` in `tweaks_md3.pas`. Verify checkboxes exist and compile cleanly.
- [x] 1.3 Populate `TWEAK_ROWS` with the new experimental items and migrate Zink and RE Engine workaround from Graphics to Experimental; update `GetTweakRowCheckBox` mapping. Verify row count matches.

## 2. Card Layout, Hit Testing & Warning Banner

- [x] 2.1 Update `Paint` in `tweaks_md3.pas` to iterate through 5 predefined categories (0..4), and render the amber header and warning banner (`INFO_BANNER_H`) on the Experimental card. Verify card renders with correct dimensions.
- [x] 2.2 Update `MouseDown`, `MouseMove`, and tooltip hover logic to offset item row coordinates by the banner height on the Experimental card. Verify toggles on the Experimental card are responsive and show correct hints.

## 3. Configuration Persistence & Predefined Filter

- [x] 3.1 Update `SaveTweaksConfig` to write `VKD3D_CONFIG=descriptor_heap`, `PROTON_VKD3D_HEAP=1`, `NGX_DLSS_RR_OVERRIDE=on`, and `VKD3D_RTAS_SIZE_MULT=8` to `[Env]` in `bgmod.conf`. Verify written INI keys.
- [x] 3.2 Update `ProcessPredefinedEnv` to detect and reload the experimental toggles from `[Env]`. Verify toggle state reload.
- [x] 3.3 Register all new experimental variables in `IsPredefinedEnvVar` so they do not leak into `[CustomVariables]`. Verify no spurious custom variables appear.

## 4. Automated Testing & Verification

- [x] 4.1 Add a GUI regression test in `tests/gui/gui_test_cases.pas` exercising the Experimental card, banner layout, dual-variable descriptor heap bundling, Ray Reconstruction, and RTAS multiplier round-trip. Verify with `make test-gui`.
