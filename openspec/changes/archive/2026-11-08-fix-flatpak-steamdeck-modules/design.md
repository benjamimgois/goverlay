# Design

## Context

See `proposal.md` for background and problem motivation.

In Goverlay's Flatpak sandbox on SteamOS:
- Extension points declared in `flatpak/io.github.benjamimgois.goverlay.yml` (`add-extensions`) are mounted by Bubblewrap into `/app/lib/extensions/vulkan/<ExtensionName>/`, not `/usr/lib/extensions/vulkan/`.
- The user's sandboxed data directory is `$XDG_DATA_HOME` (`~/.var/app/io.github.benjamimgois.goverlay/data/`).
- Goverlay's `GetGOverlayDataPath` resolves to `$XDG_DATA_HOME/goverlay/`, which is fully readable/writable inside Flatpak.
- The host SteamOS display server and compositor is **Gamescope**, which scans `/usr/share/vulkan/implicit_layer.d/` and host `~/.local/share/vulkan/implicit_layer.d/` on boot. Because Flatpak isolates `$XDG_DATA_HOME`, layer manifests placed in `$XDG_DATA_HOME/vulkan/implicit_layer.d/` do not pollute the host compositor and will never cause a SteamOS bootloop.

## Goals / Non-Goals

**Goals:**
- Eliminate "not found" false-negatives for `MangoHud` and `vkBasalt` in Flatpak by supporting both `/app/` and `/usr/` extension mount targets and reading extension metadata for version display.
- Safely enable background downloading and installation of `vkSumi`, `MAKO`, `lsfg-vk`, `afmf-linux`, `vkNemu`, and `DLSS-NR` inside Flatpak user data storage.
- Enforce `enable_environment` in all generated layer manifests, ensuring Vulkan layers only activate when explicitly requested by game environment variables.
- Maintain 100% compliance with Flathub moderation guidelines (no `--filesystem=host`, no `flatpak-spawn --host`, no host root/system directory writes).

**Non-Goals:**
- Submitting new Flatpak runtime extensions to upstream Flathub repositories (this design provisions runtimes safely in user space).
- Modifying host system implicit layer manifests outside the Flatpak sandbox.

## Decisions

### Decision 1: Dual-Path Extension Checking (`/app/` and `/usr/`)
- **Rationale**: Flathub mounts application-declared extensions under `/app/lib/extensions/vulkan/...` and runtime-declared extensions under `/usr/lib/extensions/vulkan/...`. Checking both paths in `apputils.pas`, `goverlay_system.pas`, and `home_tab.pas` guarantees robust detection regardless of whether Goverlay runs as a nightly, stable Flatpak, or future runtime migration.
- **Alternatives considered**: Checking only `/app/`. Rejected because future base runtimes or development builds could mount extensions at `/usr/`.

### Decision 2: Flatpak Extension Version Extraction
- **Rationale**: `GetMangoHudVersion` and `GetVkBasaltVersion` currently exit immediately when `IsRunningInFlatpak` is true because package managers (`pacman`, `dpkg`) cannot inspect host packages from inside the sandbox. In Flatpak, the version can be parsed reliably by reading `/app/lib/extensions/vulkan/<name>/manifest.json` or by reading the layer version string from `share/vulkan/implicit_layer.d/*.json`.
- **Alternatives considered**: Hardcoding static versions. Rejected because Flathub updates extensions independently of Goverlay releases.

### Decision 3: Sandbox User-Space Storage for Companion Layers
- **Rationale**: When running in Flatpak, `CheckAndInstallVkSumi`, `CheckAndInstallMako`, `CheckAndInstallLsfgVk`, `CheckAndInstallAfmf`, and `CheckAndInstallVkNemu` will store libraries inside `$XDG_DATA_HOME/goverlay/layers/<module>/` rather than attempting to write to host `~/.local/lib/` or `/usr/local/`. This operates within permitted Flatpak sandbox filesystem boundaries without requiring elevated manifest permissions.
- **Alternatives considered**: Requiring users to install layers on the host via desktop terminal scripts. Rejected because the first-run onboarding wizard should provide a turn-key experience for Steam Deck users.

### Decision 4: Safe Manifest Generation with `enable_environment`
- **Rationale**: Vulkan layer manifests written to `$XDG_DATA_HOME/vulkan/implicit_layer.d/` will include an `"enable_environment"` trigger (e.g. `"ENABLE_VKSUMI": "1"`). Even if a host process or sub-sandbox mounts this directory, Vulkan ignores the layer unless the specific environment variable is active. This completely eliminates any risk of crashing Gamescope.
- **Alternatives considered**: Using explicit layers without manifests. Rejected because Goverlay's game profile generator relies on layer manifests with environment variable triggers.

### Decision 5: Integrate DLSS-NR into Startup Download Thread
- **Rationale**: `CheckAndInstallDlssNr` will be called within `TStartupDownloadThread.Execute` when `TConfigManager.IsModuleEnabled(MODULE_UPSCALERS)` is true, matching the provisioning flow of OptiScaler and DLSS Enabler.
- **Alternatives considered**: Deferring DLSS-NR downloads until individual game configuration. Rejected because user expectations on first-run setup are that all checked modules are installed and ready.

## Risks / Trade-offs

- **[Risk] Slower first boot splash when multiple modules are selected** → **Mitigation**: Downloads are already threaded and report progress per-module on the boot splash screen.
- **[Risk] Corrupted downloads on unstable Wi-Fi** → **Mitigation**: Existing curl downloads enforce `--fail` and validate ELF headers and file size with `IsValidSharedLibrary` before writing manifest files.
