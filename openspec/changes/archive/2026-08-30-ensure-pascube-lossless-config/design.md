## Context

GOverlay manages Lossless Scaling configuration through `TLosslessScalingTabHelper` (`lossless_scaling_tab.pas`) and `openConfigFileMenuItemClick` in `overlayunit.pas`.
Currently, `WriteLsfgTomlConfig` writes `pascube` and `vkcube` blocks when frame generation is active (multiplier > 1), but opening the configuration file from the hamburger menu opens whatever existing `lsfg.toml` is on disk (often an old upstream template) without ensuring the active UI state and `pascube` entry are written.

## Goals / Non-Goals

**Goals:**
- Guarantee that `openConfigFileMenuItemClick` flushes the active UI state to `lsfg.toml` containing `pascube` and `vkcube` blocks before launching the external editor (`xdg-open`).
- Ensure fallback / template creation initializes `lsfg.toml` with `pascube` support.
- Ensure that opening `lsfg.toml` even when frame generation is at 1x produces a structured file with `pascube` and `vkcube` entries instead of an empty file.

**Non-Goals:**
- Modifying system-wide `/etc/lsfg.toml` or external standalone `~/.config/lsfg/lsfg.toml` outside GOverlay's managed configuration scope.

## Decisions

### 1. Flush active configuration on "Open config file"
In `overlayunit.pas` (`openConfigFileMenuItemClick`), when active tab is `losslessScalingTabSheet`, call `TLosslessScalingTabHelper.SaveLosslessConfig` (or `WriteLsfgTomlConfig`) to ensure `lsfg.toml` on disk accurately mirrors the UI state and contains `pascube` entries prior to invoking `xdg-open`.

### 2. Generate valid default `lsfg.toml` with `pascube` on demand
If `SaveLosslessConfig` is triggered while multiplier is 1x (inactive) or when opening the file, ensure a valid TOML template with `[global]` and `[[game]] exe = "pascube"` / `[[game]] exe = "vkcube"` is written so users can inspect and edit a complete configuration structure.

## Risks / Trade-offs

- **[Overwriting manual edits outside GOverlay]** → GOverlay UI is the authoritative visual configurator for GOverlay-managed directories (`gameconfig/global/` and `gameconfig/<game>/`), matching the behavior of MangoHud, vkBasalt, and OptiScaler.
