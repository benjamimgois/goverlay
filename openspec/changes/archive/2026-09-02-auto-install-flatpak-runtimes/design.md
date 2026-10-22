## Context

See `proposal.md` for motivation.

Goverlay relies on Vulkan layers for MangoHud, vkBasalt, and vkSumi. Under Flatpak, Vulkan layers must either be mounted via runtime extension points or registered in user-accessible Vulkan search paths (`$XDG_DATA_HOME/vulkan/implicit_layer.d/`).

Currently:
- Flatpak manifests (`io.github.benjamimgois.goverlay.yml`) do not declare `add-extensions`, requiring users to manually run `flatpak install org.freedesktop.Platform.VulkanLayer.MangoHud//25.08 org.freedesktop.Platform.VulkanLayer.vkBasalt//25.08`.
- vkSumi is not available on Flathub, requiring a manual standalone `.flatpak` bundle installation.
- The startup boot splash thread (`TStartupDownloadThread`) already implements a reliable curl/progress mechanism for OptiScaler and DLSS Enabler that can be extended for vkSumi.

## Goals / Non-Goals

**Goals:**
- Zero-click installation of MangoHud and vkBasalt Flatpak extensions upon installing Goverlay from Flathub or app stores.
- Automatic download, extraction, and manifest registration of vkSumi into `~/.local/share/goverlay/layers/vksumi/` and `~/.local/share/vulkan/implicit_layer.d/` during the startup boot splash.
- Seamless recognition of user-space Vulkan layers in `goverlay_system.pas` and `home_tab.pas`.
- Streamlined documentation in `README.md` removing manual extension installation commands.

**Non-Goals:**
- Building and bundling full Vulkan layers directly inside the Flatpak `/app` binary (which would not be accessible to host/Steam games).
- Attempting to spawn host commands or escape the Flatpak sandbox.

## Decisions

### Decision 1: Manifest `add-extensions` with `autodownload: true` for MangoHud & vkBasalt
- **Rationale**: Flathub officially supports automatic extension downloading when declared in the application manifest with `autodownload: true`. This integrates natively with Flatpak CLI, GNOME Software, and KDE Discover without any sandbox violations or custom scripts.
- **Alternatives Considered**:
  - *Host flatpak-spawn*: Prohibited by Flathub policy.
  - *Bundling inside /app*: Only makes PasCube work, does not share layers with external games.

### Decision 2: User-space Layer Installation for vkSumi (`~/.local/share/vulkan/`)
- **Rationale**: vkSumi is not currently hosted as a Flathub extension. The Vulkan loader standard searches `$XDG_DATA_HOME/vulkan/implicit_layer.d/*.json`. By downloading the compiled `libVkLayer_vksumi.so` to `~/.local/share/goverlay/layers/vksumi/` and generating `vksumi.json` in `~/.local/share/vulkan/implicit_layer.d/`, vkSumi becomes immediately available to both Goverlay (PasCube preview) and games, without requiring root or flatpak daemon intervention.
- **Alternatives Considered**:
  - *Downloading `.flatpak` bundle to disk*: Still requires the user to manually run `flatpak install` in a terminal.

### Decision 3: Startup Boot Splash Integration (`TStartupDownloadThread`)
- **Rationale**: `TStartupDownloadThread` in `overlayunit.pas` already coordinates download progress across components. Allocating progress ranges (OptiScaler: 0–40%, DLSS Enabler: 40–70%, vkSumi: 70–95%, Finalize: 95–100%) provides a smooth visual feedback loop without UI blocking.

## Risks / Trade-offs

- **[Risk] GitHub API rate limiting for vkSumi releases** → Mitigation: Use direct release download fallback URLs (matching how OptiScaler and DLSS Enabler fallbacks are structured in `optiscaler_update.pas`).
- **[Risk] Flatpak runtime branch mismatches** → Mitigation: Ensure `io.github.benjamimgois.goverlay.yml` and `io.github.benjamimgois.goverlay.nightly.yml` declare `version: '25.08'` matching the runtime base.
- **[Risk] Missing user vulkan directory** → Mitigation: Create `~/.local/share/vulkan/implicit_layer.d/` recursively (`ForceDirectories`) before writing `vksumi.json`.
