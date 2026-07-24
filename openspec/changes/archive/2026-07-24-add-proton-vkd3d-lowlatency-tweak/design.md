## Context

GOverlay manages environment variable tweaks via the `TWEAK_ROWS` array in `tweaks_md3.pas` and backing hidden `TCheckBox` controls on `FForm` (`overlayunit.pas`). Each tweak entry specifies a category ('General', 'Graphics', 'Performance', 'Latency reduction'), variable name (`PROTON_VKD3D_LOWLATENCY=1`), and description.

## Goals / Non-Goals

**Goals:**
- Add `PROTON_VKD3D_LOWLATENCY=1` as a built-in tweak under `'Latency reduction'`.
- Format description as `"[proton-cachyos] low-latency frame pacing capabilities"`.
- Wire checkbox persistence and `goverlay.vars` / `bgmod.conf` generation.

**Non-Goals:**
- Modifying non-latency tweaks or other tabs.

## Decisions

1. **Category Placement: `'Latency reduction'`**
   - Rationale: `PROTON_VKD3D_LOWLATENCY` directly affects frame pacing and input latency in VKD3D Direct3D 12 games. Placing it alongside Anti-Lag and Korthos low latency layer options keeps related tweaks grouped together.

2. **Description formatting: `"[proton-cachyos] low-latency frame pacing capabilities"`**
   - Rationale: Prefixed with `[proton-cachyos]` to inform users which Proton distro provides native support.
