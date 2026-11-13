# Design

## Context

`tweaks_md3.pas` defines `TWEAK_ROWS` using category constants `TWEAK_CAT_GENERAL` (0) through `TWEAK_CAT_EXPERIMENTAL` (4), plus `TWEAK_CAT_CUSTOM` (5) and `TWEAK_CAT_ARGS` (6). Several loops and arrays in `tweaks_md3.pas` (such as `CatNames` and `for CatIdx := 0 to 4`) assume predefined categories occupy indices `0..N`. Badge rendering in `tweaks_md3.pas` inspects description prefixes (`[proton-cachyos]`, `[MESA]`, `[low_latency_layer]`) to draw colored pill badges.

## Goals / Non-Goals

**Goals:**
- Add `TWEAK_CAT_CONTROLLERS` as a predefined category card rendered alongside the existing categories.
- Add a `[GE]` / `[proton-ge]` badge branch in `tweaks_md3.pas` with distinct styling.
- Move `PROTON_USE_SDL=1` to `TWEAK_CAT_CONTROLLERS`.
- Add `PROTON_ZLUDA=1` (`TWEAK_CAT_EXPERIMENTAL`) and the 5 Proton-GE controller variables (`TWEAK_CAT_CONTROLLERS`), with full checkbox, `configkeys.pas`, save, load, and clear-state wiring.

**Non-Goals:**
- Adding `PROTON_PREFER_SDL=1`, `PROTON_DEATH_STRANDING_CONTROLLER_EFFECTS=1`, `WINE_*`, or `DXVK_*` variables.

## Decisions

1. **Category index ordering (`TWEAK_CAT_CONTROLLERS = 4`, shifting `EXPERIMENTAL = 5`, `CUSTOM = 6`, `ARGS = 7`)**
   - *Rationale*: Keeps `Experimental` (with its warning banner) as the last predefined card before `Custom` and `Launch Arguments`, matching user expectations. All `CatIdx` loops (`0..4` -> `0..5`) and `CatNames` arrays (`0..4` -> `0..5`) in `tweaks_md3.pas` will be updated consistently.
   - *Alternative*: Assigning `TWEAK_CAT_CONTROLLERS = 7` after `ARGS` — rejected because `for CatIdx := 0 to N` assumes contiguous predefined category indices.

2. **Handling `PROTON_SONY_AUTO_XINPUT=0` persistence**
   - *Rationale*: Unlike `=1` flags, `PROTON_SONY_AUTO_XINPUT=0` disables an automatic fallback by writing `'0'`. `SaveTweaksConfig` must write `'0'` when checked, and `LoadTweaksFromFGMod` must check the box when `V = '0'`.

3. **Distinct `GE` badge styling**
   - *Rationale*: Use a teal/emerald or warm amber-orange pill (`BadgeText := 'GE'`) distinct from `CachyOS` (purple), `MESA` (blue), `RADEON` (red), and `NVIDIA` (green).

## Risks / Trade-offs

- **Hardcoded `0..4` category bounds in `tweaks_md3.pas` hit-testing/painting** → **Mitigation**: Search all occurrences of `CatNames`, `TWEAK_CAT_EXPERIMENTAL`, and `0 to 4` in `tweaks_md3.pas` and update them together, then compile with `lazbuild` and verify UI layout.
