## Context

GOverlay manages Lossless Scaling frame generation via `lossless_scaling_tab.pas`, supporting multiple interpolation engines (`imNone`, `imLsfg`, and `imMako`). Previously, `imLsfg` targeted `lsfg-vk` 1.0 using legacy `version = 1` files (`lsfg.toml`) with `[[game]]` blocks and legacy environment variables (`LSFG_CONFIG`).

With `lsfg-vk` 2.0 released at `git.lsfg-vk.dev`, the engine adopted a `version = 2` profile configuration schema (`conf.toml`), renamed the Vulkan layer to `VkLayer_LSFGVK_frame_generation.json`, introduced new presentation quirks (`override_present_mode` and `preserve_swapchain_image_count`), consolidated `allow_fp16` in `[global]`, and removed `hdr_mode` and `gpu` configuration properties. See `proposal.md` for full motivation.

## Goals / Non-Goals

**Goals:**
- Provide full support for `lsfg-vk` 2.0 configuration, layer detection, and execution environment.
- Integrate the two new quirks (`Override Present Mode` and `Preserve Swapchain Image Count`) alongside existing Frame Generation toggles.
- Add an automated download step in the startup splash screen for native environments using official binaries from `https://builds.lsfg-vk.dev/`.
- Support Flatpak cleanly by adding the official Flathub extension `org.freedesktop.Platform.VulkanLayer.lsfgvk` and granting `xdg-config/lsfg-vk:create` access, avoiding sandbox permission violations.
- Provide clean coexistence between `imLsfg` (standard upstream engine) and `imMako` (custom fork with adaptive FG and spatial upscaling).

**Non-Goals:**
- Injecting MAKO-exclusive properties into `lsfg-vk` config files (upstream `lsfg-vk` parser aborts execution if unknown keys are detected).
- Redesigning the entire Lossless Scaling tab layout.

## Decisions

### Decision 1: Dedicated Strict TOML Serialization for lsfg-vk 2.0
- **Rationale**: Upstream `lsfg-vk` 2.0 uses `toml++` in `config.cpp` and explicitly raises a `std::runtime_error("Unknown key in profile section: " + key)` if any unrecognized key appears in `[global]` or `[[profile]]`. Therefore, `WriteLsfgTomlConfig` must produce clean TOML containing only standard keys: `version = 2`, `[global]` (`dll`, `allow_fp16`), and `[[profile]]` (`name`, `active_in`, `multiplier`, `flow_scale`, `performance_mode`, `pacing`, `override_present_mode`, `preserve_swapchain_image_count`).
- **Alternatives considered**: Sharing a single serializer with MAKO. Rejected because MAKO keys (`adaptive`, `scaling_method`, etc.) cause `lsfg-vk` to crash.

### Decision 2: Hybrid Installation Architecture (Native vs Flatpak)
- **Rationale**: In Flatpak packages (Flathub), GOverlay runs in a sandbox where writing to host `~/.local/bin` and `~/.local/lib` is disallowed by sandbox boundaries and Flathub security policies.
  - In Flatpak (`IsRunningInFlatpak = true`): GOverlay relies on `org.freedesktop.Platform.VulkanLayer.lsfgvk` in `io.github.benjamimgois.goverlay.yml` `add-extensions` (`autodownload: true`). The startup download routine detects the extension and skips `curl`/`tar` extraction.
  - In Native / AppImage: GOverlay's startup thread downloads `lsfg-vk-2.0.0.tar.xz` from `https://builds.lsfg-vk.dev/` and extracts to `~/.local/`, as officially recommended by upstream.
- **Alternatives considered**: Attempting to extract into host `~/.local` from inside Flatpak. Rejected due to sandbox isolation and Flathub rejection.

### Decision 3: Grouping Quirks Toggles with Frame Generation
- **Rationale**: As requested by the user, the new `Override Present Mode` (default: ON) and `Preserve Swapchain Image Count` (default: OFF) toggles are integrated directly into the Frame Generation toggles area next to `Performance Mode` and `Allow FP16`. They are visible only when `imLsfg` is selected.
- **Alternatives considered**: Creating a separate "Quirks" sub-panel. Rejected to keep the UI clean and avoid unnecessary vertical clutter.

### Decision 4: Multiplier 1x as Bypass Mode
- **Rationale**: In `lsfg-vk` 2.0, multiplier `1` acts as a bypass mode. The trackbar range is configured from 1 to 4 (or higher), displaying `1x (Bypass)` when at position 1.

## Risks / Trade-offs

- `[Risk] Upstream tarball URL changes across minor updates` → Mitigation: Scrape `https://builds.lsfg-vk.dev/` dynamically or maintain a validated release fallback URL.
- `[Risk] Residual v1 lsfg.toml files causing confusion` → Mitigation: When saving under `imLsfg`, GOverlay generates `conf.toml` and exports `LSFGVK_CONFIG` pointing to it.
- `[Risk] Old Vulkan layer left behind on host` → Mitigation: Priority check checks `VkLayer_LSFGVK_frame_generation.json` first, and `lsfg-vk-cli healthcheck` is used where available.
