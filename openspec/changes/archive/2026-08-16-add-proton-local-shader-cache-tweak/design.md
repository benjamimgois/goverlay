## Context

GOverlay manages built-in environment variable tweaks in `tweaks_md3.pas` using the `TWEAK_ROWS` constant array, rendered on a Material Design 3 style custom canvas. Each row is backed by a hidden `TCheckBox` component on `Tgoverlayform`.

Proton-CachyOS supports `PROTON_LOCAL_SHADER_CACHE=1` to store shader caches locally within each game's prefix or working directory.

## Goals / Non-Goals

**Goals:**
- Add `PROTON_LOCAL_SHADER_CACHE=1` to `TWEAK_ROWS` under `TWEAK_CAT_PERF` ("Performance").
- Description: `"[proton-cachyos] Enable per-game shader cache"`.
- Purple prefix color `RGBToColor(160, 120, 240)` via the existing `[proton-cachyos]` prefix parser.
- Backing checkbox `FProtonLocalShaderCacheCheckBox` mapped at index 29 in `GetTweakRowCheckBox`.
- Save and load `PROTON_LOCAL_SHADER_CACHE=1` from `bgmod.conf` in the `[Env]` section.
- Add tooltip `"Works only with proton-cachyos"`.

**Non-Goals:**
- Altering the handling of other tweaks or custom environment variables.

## Decisions

### 1. Category Placement: Performance (`TWEAK_CAT_PERF`)
- Placed under the Performance category alongside game priorities, memory optimizations, and thread/sync options.

### 2. Checkbox Backing Control
- Declared as `FProtonLocalShaderCacheCheckBox` in `Tgoverlayform` in `overlayunit.pas`.
- Instantiated dynamically in `InitTweaksCards` in `tweaks_md3.pas`.

## Risks / Trade-offs

- None identified.
