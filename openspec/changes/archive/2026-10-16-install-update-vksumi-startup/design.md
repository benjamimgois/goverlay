# Design: Install and Update vkSumi on Startup

## Context

See `proposal.md` for background and motivation.
Goverlay already has `CheckAndInstallVkSumi` in `optiscaler_update.pas` which can fetch GitHub releases, extract `libVkLayer_vksumi.so`, and write `vksumi.json`. However, `HasMissingMandatoryLibraries` never audits vkSumi on disk, preventing missing downloads during first boot. Furthermore, Goverlay does not record the installed vkSumi release version, nor does it check for updates against GitHub releases.

## Goals / Non-Goals

**Goals:**
- Detect missing vkSumi Vulkan layer (`libVkLayer_vksumi.so` / `vksumi.json`) in `HasMissingMandatoryLibraries` and trigger the startup boot splash.
- Implement `ReadLocalVkSumiVersion: string` and `IsVkSumiUpdateAvailable: Boolean` in `optiscaler_update.pas`.
- Persist installed release version in `goverlay.vars` (e.g., `vksumi=v0.1.0`) and in `layers/vksumi/version.txt`.
- Trigger `TStartupDownloadThread` when an update is available or files are missing.
- Update fallback download URL to `v0.1.0`.

**Non-Goals:**
- Downloading host Vulkan layers inside Flatpak (guarded by `IsRunningInFlatpak`).
- Adding a dedicated GUI update button on the vkBasalt tab (startup lifecycle handles updates automatically).

## Decisions

### 1. Version Tracking in `goverlay.vars` and Layer Directory
- **Decision**: Persist `vksumi=<tag>` in `goverlay.vars` (in both cache and global config directories, following `OptiPatcher` and `DLSS` convention), as well as a fallback `version.txt` inside `~/.local/share/goverlay/layers/vksumi/`.
- **Rationale**: `goverlay.vars` is the established single-file version registry for Goverlay components. Having the local fallback in the layer directory provides resilience if `goverlay.vars` is rebuilt.
- **Alternatives considered**: Parsing `strings libVkLayer_vksumi.so` at runtime — discarded because stripped binaries may not reliably export clean semantic version strings.

### 2. Lightweight GitHub Release Query with Timeout
- **Decision**: Use `curl` with `--connect-timeout 2 --max-time 4` to check `https://api.github.com/repos/reakjra/vkSumi/releases/latest`. If curl fails, returns empty, or encounters an API rate limit, `IsVkSumiUpdateAvailable` gracefully returns `False`.
- **Rationale**: Application startup must never hang due to poor network connectivity or GitHub outages.
- **Alternatives considered**: Background timer polling — unnecessary since startup check covers launching sessions cleanly.

### 3. Inclusion in `HasMissingMandatoryLibraries`
- **Decision**: In `HasMissingMandatoryLibraries`, check if system layer or user-space `~/.local/share/goverlay/layers/vksumi/libVkLayer_vksumi.so` and manifest `~/.local/share/vulkan/implicit_layer.d/vksumi.json` exist. If absent and not running in Flatpak, add `'vkSumi Vulkan layer'` to `AMissingList`.
- **Rationale**: Ensures first-time users or users with cleaned configurations automatically receive vkSumi via the boot splash.

## Risks / Trade-offs

- **[GitHub API Rate Limiting (403)]** → Fast timeout (2s/4s) and silent fallback to `False` ensures startup is never blocked; fallback URL allows successful manual or forced installation.
- **[Corrupted Archive Download]** → `CheckAndInstallVkSumi` already verifies `IsValidSharedLibrary` before generating the manifest; invalid files are deleted immediately.
- **[Flatpak Sandbox Constraints]** → Strict `IsRunningInFlatpak` guard remains active, preventing attempts to modify host implicit layers.
