# Proposal

## Why

In the Post Processing tab when the vkBasalt method is selected, the "Reshade effects" card displays multiple duplicate effects (e.g., duplicate entries for "FXAA", "SMAA", and "UIDetect"). This occurs because `ListFilesToListBox` scans for `['.fx', '.fxh', '.h', '.glsl']`, and the friendly effect name in the UI is computed by stripping the file extension (`ChangeFileExt(ExtractFileName(Path), '')`). Consequently, `.fx` and `.fxh` pairs share the same base name and are both added to the list. Non-runnable C/HLSL header files like `DrawText.fxh`, `Macros.fxh`, `ReShade.fxh`, and `ReShadeUI.fxh` also get listed as effects.

Additionally, "FXAA", "SMAA", and "LUT" appear in the ReShade effects list even though vkBasalt provides dedicated native implementations in the "Built-in Effects" card below (Vulkan compute shaders for FXAA and SMAA, and native 3D LUT loader) that perform significantly better and avoid configuration conflicts.

## What Changes

- Filter available shader file extensions: Scan only for executable shader files (`.fx`, `.glsl`) and exclude header/include files (`.fxh`, `.h`).
- Deduplicate effect entries: Ensure each base effect name is added at most once to `aveffectsListbox` (case-insensitive deduplication), preventing duplicates if files exist across multiple subdirectories or extensions.
- Exclude built-in effects from the ReShade effects list: Expose `IsVkBasaltBuiltInEffect` and exclude built-in effects (`FXAA`, `SMAA`, `LUT`, `CAS`, `DLS`) from being listed in `aveffectsListbox` since they are provided as native built-in controls in the card below.
- Add test coverage in `tests/gui/gui_test_cases.pas` verifying that `.fxh` headers, duplicates, and built-in FXAA/SMAA/LUT are excluded from `aveffectsListbox`.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `vkbasalt-builtin-effects-serialization`: Add requirement for available ReShade effects listing and filtering to guarantee unique entries, exclude `.fxh`/`.h` headers, and exclude built-in effects (FXAA, SMAA, LUT) from the ReShade effects list.

## Impact

- `overlay_config.pas`: Expose `IsVkBasaltBuiltInEffect` in interface.
- `overlayunit.pas`:
  - Update `ListFilesToListBox` to enforce case-insensitive deduplication by base effect name and exclude effects matching `IsVkBasaltBuiltInEffect` (including `FXAA`, `SMAA`, and `LUT`).
  - Update callers in `overlayunit.pas` and `vkbasalt_tab.pas` to pass only `['.fx', '.glsl']` instead of including `.fxh` and `.h`.
- `tests/gui/gui_test_cases.pas`: Add test case verifying deduplication, exclusion of `.fxh` headers, and exclusion of FXAA, SMAA, and LUT.
