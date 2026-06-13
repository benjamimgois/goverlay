## Why

The PasCube benchmark feature in GOverlay fails or does not persist results on Ubuntu, Bazzite, and NixOS systems (and other distributions using Flatpak, Nix packages, or global package managers). This occurs because it attempts to write and read `benchmark_results.json` directly next to its binary in read-only installation directories (such as `/usr/libexec`, `/nix/store/...`, or `/app/libexec`), fails to query the correct host OS inside containerized flatpak environments, and strictly requires the `7z` command which may be missing or named differently (e.g. `7za` or `7zz`) on certain setups.

## What Changes

- **User-agnostic config path resolution**: Modify `pascube`'s benchmark results loading, saving, and deletion logic to use a writeable XDG user configuration path (specifically `~/.config/goverlay/benchmark_results.json`) instead of the read-only directory next to the binary. This works seamlessly across Flatpak, NixOS store installations, and system-wide packages.
- **Flatpak-aware OS detection**: Improve the OS name detection logic in PasCube to look for the host's `/run/host/etc/os-release` or `/run/host/usr/lib/os-release` when running inside Flatpak sandboxes, ensuring accurate system details are captured.
- **Improved developer environment fallback**: Eliminate the hardcoded `/home/benjamim` fallback paths when checking config directories in PasCube, using standard writeable temporary locations (like `/tmp`) as a safer alternative.
- **Robust 7-Zip command check**: Add a wider range of fallbacks (`7z`, `7zz`, `7za`) to verify and spawn 7-Zip compression during CPU benchmarking to avoid execution freezes when `7z` or `7zz` are missing.

## Capabilities

### New Capabilities
- `pascube-benchmark-compatibility`: Specifies requirements for cross-distribution (including NixOS), sandboxed (Flatpak), and native compatibility of the PasCube system benchmark.

### Modified Capabilities
<!-- Leave empty if no requirement changes. -->

## Impact

- **Affected components**: PasCube source (`pascube_src/src/UnitPasCubeScreen.pas`)
- **No API changes**: Self-contained internal changes in PasCube.
- **No breaking changes**: Localized compatibility fixes that preserve all original save/load behavior but redirect storage locations.
