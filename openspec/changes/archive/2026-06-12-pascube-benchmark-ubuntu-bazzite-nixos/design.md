## Context

The PasCube Vulkan-based benchmark executes within GOverlay to measure CPU and GPU performance. However, because it was developed in a local environment, it makes assumptions about directory write access (writing results next to its own binary) and OS release locations that break when run in containerized sandboxes (like Flatpak), under read-only nix stores (like NixOS), or installed natively under system directories (like `/usr/libexec/pascube`).

## Goals / Non-Goals

**Goals:**
- Redirect `benchmark_results.json` to a user-writeable XDG config directory.
- Ensure host OS detection (e.g. Bazzite, NixOS, or Ubuntu) works accurately inside Flatpak.
- Remove developer-specific hardcoded paths from PasCube config helpers.
- Provide comprehensive fallback verification for 7-Zip commands (`7z`, `7zz`, `7za`) during benchmarks.

**Non-Goals:**
- Changing the benchmark physics simulation or scoring algorithms.
- Modifying how GOverlay launches or communicates with PasCube.

## Decisions

### Decision 1: Writeable Configuration Path for Results
- **Approach**: Define `GetBenchmarkResultsFilePath()` in `UnitPasCubeScreen.pas` to resolve the path `~/.config/goverlay/benchmark_results.json` (resolving via `XDG_CONFIG_HOME` and falling back to `HOME` + `/.config`).
- **Rationale**: Since `/app/`, `/nix/store/`, and `/usr/` are read-only system paths, local storage next to the binary fails. Consolidating the file in the existing `goverlay` config folder matches the project's standard XDG layout and ensures user write access.
- **Alternatives Considered**: Storing under `/tmp/` (results would be lost on reboot) or `~/.local/share/goverlay/` (config directory is cleaner for static benchmark history).

### Decision 2: Flatpak Host OS Detection
- **Approach**: Scan `/run/host/etc/os-release` and `/run/host/usr/lib/os-release` before querying the standard `/etc/os-release`.
- **Rationale**: Flatpak containers mount the host OS filesystem under `/run/host`. Checking these paths first allows the benchmark to detect the host distro (Bazzite, NixOS, Ubuntu, Fedora) instead of the generic Flatpak container runtime name.

### Decision 3: Remove Hardcoded Developer Fallback
- **Approach**: Change the default fallback home directory from `/home/benjamim` to a generic path (e.g. `/tmp` or letting the command fail gracefully with a safe directory) when resolving the home configuration paths in `GetSubmitURL` and `GetBenchmarkResultsFilePath`.
- **Rationale**: Avoids permission or write errors for other users whose home folders do not contain `/home/benjamim`.

### Decision 4: Add 7za to the 7-Zip Fallback List
- **Approach**: Update the shell command script executed by `T7ZipThread` to search for `7za` if both `7z` and `7zz` are missing.
- **Rationale**: Some Debian/Ubuntu/NixOS packages install `7za` instead of `7z`/`7zz`. Adding it ensures the CPU benchmark doesn't fail silently.

## Risks / Trade-offs

- **[Risk]**: The config directory `~/.config/goverlay` might not exist when PasCube starts.
  - **Mitigation**: The system will explicitly call `ForceDirectories` on the resolved directory before returning the file path.
- **[Risk]**: Inside Flatpak, the application might lack access to host paths if permissions are missing.
  - **Mitigation**: The sandbox finish arguments already allow GPU/filesystem access, and `/run/host` read access is standard for Flatpak packages to detect host environment details.
