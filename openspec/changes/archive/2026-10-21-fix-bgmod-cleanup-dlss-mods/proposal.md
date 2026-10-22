# Proposal

## Why

When ReShade is enabled with OptiScaler disabled, `bgmod` writes `reshadeproxy=` into `goverlay.vars`, triggering the disabled-OptiScaler cleanup routine on all subsequent launches. Because native DLSS and Streamline DLLs (`nvngx_dlss*.dll`, `sl.*.dll`) are not treated as protected native game DLLs when backups are absent, and proxy ownership fallback relies solely on `bgmod.conf` filename entries, the cleanup erroneously deletes genuine game files, mod loaders like Cyber Engine Tweaks (`version.dll`), and third-party mod directories (`OptiScaler/`). Fixing this prevents game corruption and ensures cleanup routines only touch files deployed by GOverlay.

## What Changes

- **Isolate OptiScaler cleanup trigger**: In `bgmod.lpr`, gate the disabled-OptiScaler cleanup check specifically on OptiScaler markers (`proxydll`, `upscalertype`, legacy upscaler keys in `goverlay.vars`, or physical OptiScaler binaries) so that a ReShade-only `goverlay.vars` (`reshadeproxy`) never triggers OptiScaler cleanup.
- **Protect native game DLLs during cleanup**: Prevent `SafeCleanOrRestore` and disabled-mod cleanup loops from deleting files in `OrigDlls` (including `nvngx_dlss*.dll`, `sl.*.dll`, `amd_fidelityfx_loader_dx12.dll`) when no backup exists in `BackupsDir`, unless the file's size/hash matches a known GOverlay payload in `SourceDir`.
- **Verify proxy ownership by payload**: Ensure `IsGOverlayProxyFile` verifies actual file payload (size/hash matching GOverlay's distributed proxy binaries) rather than relying blindly on `DLL=` in `bgmod.conf`, preventing accidental deletion of third-party mod loaders such as Cyber Engine Tweaks (`version.dll`) or RED4ext (`winmm.dll`).
- **Protect third-party mod directories**: Guard the removal of `OptiScaler/` directory so it is only removed if created by GOverlay and not managed by external mod managers (such as Vortex's `__folder_managed_by_vortex`) or containing third-party files.
- **Support space-less launcher rules**: Update launcher path matching in `bgmod.lpr` to match game directory names both with and without spaces (e.g. `Cyberpunk 2077` and `Cyberpunk2077` for Heroic/GOG installations).

## Capabilities

### New Capabilities
*(None)*

### Modified Capabilities
- `proxy-dll-management`: Clarify and strengthen proxy ownership verification to validate deployed file payloads rather than trusting bare configuration filenames, ensuring third-party mod loaders sharing proxy DLL names are never deleted when a tool is disabled.
- `safe-uninstall-backup-restore`: Extend non-deletion protections for native vendor libraries (DLSS, Streamline, Reflex, FidelityFX) from the standalone uninstaller to `bgmod` runtime disabled-tool cleanup routines when no backup exists.

## Impact

- **Affected Code**: `bgmod.lpr`, `bgmod-uninstaller.lpr`, and potentially launcher rule tables in `bgmod.lpr`.
- **Binaries**: Requires recompilation of `bgmod` and `bgmod-uninstaller`.
- **Compatibility**: Backwards compatible with existing configurations; eliminates game file corruption in games with native DLSS/Streamline when running with ReShade or switching mod configurations.
