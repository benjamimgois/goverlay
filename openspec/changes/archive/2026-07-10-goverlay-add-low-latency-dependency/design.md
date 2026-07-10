## Context

GOverlay manages Vulkan layers and overlays (like MangoHud and vkBasalt). The `vulkan-low-latency-layer` is an implicit layer that reduces input latency. It is installed either natively (e.g. from AUR via `vulkan-low-latency-layer-git` or distro packages) or via Flatpak. GOverlay needs to detect and present its status on the Home tab.

## Goals / Non-Goals

**Goals:**
- Detect if `vulkan-low-latency-layer` is installed natively by checking for `low_latency_layer.json` in common Vulkan implicit layer directories, or testing if `libVkLayer_KORTHOS_LowLatency` shared library is available.
- Present the dependency status on the Home tab's "Dependencies" section.
- Expand the dependency grid to 3x3 to avoid UI overflow.

**Non-Goals:**
- Provide automatic installation or configuration of the low latency layer.

## Decisions

### 1. Detection Paths and Check Logic
We will check the following paths sequentially inside `CheckDependencies` in both `goverlay_system.pas` and `apputils.pas`:
- `/usr/share/vulkan/implicit_layer.d/low_latency_layer.json`
- `/etc/vulkan/implicit_layer.d/low_latency_layer.json`
- `~/.local/share/vulkan/implicit_layer.d/low_latency_layer.json` (evaluated via `GetUserDir + '.local/share/...'`)
- Shared library check: `IsLibraryAvailable('libVkLayer_KORTHOS_LowLatency')`

*Alternatives considered:* Checking package database directly (e.g., `pacman -Q`).
*Rationale:* File presence and library checks are fast, distro-agnostic, and also cover custom/manual compilations of the layer.

### 2. UI Layout Expansion in `home_tab.pas`
Currently, the "Dependencies" card is built using a 3x2 grid (looping 0 to 5) with a height of `CARD_P * 2 + 24 + 2 * ROW_H + 8`.
We will:
- Increase the card height to `CARD_P * 2 + 24 + 3 * ROW_H + 8` to hold a third row.
- Loop `0 to 6` in the drawing block.
- Place the "Low Latency" dependency at index 6 (start of the 3rd row, at column 0).

## Risks / Trade-offs

- **[Risk]** The dependency name might conflict or be too wide.
  - *Mitigation*: We will use the label `"Low Latency"` for display, which fits well within `COL_W` constraints.
