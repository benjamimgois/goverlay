## Context

OptiScaler integrates with GOverlay to swap FSR upscaler DLLs depending on user configurations. This swapping relies on specific DLLs being located in `FSR4_LATEST` and `FSR4_INT8` directories. Since GOverlay updates overwrite the working copy from `.bgmod_original`, these subdirectories and DLLs must be automatically managed inside `.bgmod_original` and synchronized to `bgmod/`.

## Goals / Non-Goals

**Goals:**
- Automatically create `FSR4_LATEST` and `FSR4_INT8` directories.
- Copy the default extracted `amd_fidelityfx_upscaler_dx12.dll` to `FSR4_LATEST`.
- Download the INT8-compatible `amd_fidelityfx_upscaler_dx12.dll` to `FSR4_INT8`.
- Ensure that updates to sync commands copy these folders recursively.

**Non-Goals:**
- Modifying how FSR versions are applied in the game wrappers or `overlay_config.pas`.

## Decisions

- **Folder Names**: Keep directory names exactly as `FSR4_LATEST` and `FSR4_INT8` matching what `overlay_config.pas` checks.
- **Network Errors**: If downloading the INT8 DLL fails, log a warning but allow the installation of OptiScaler to finish successfully, as the user can still use the "Latest" version.

## Risks / Trade-offs

- [Risk] Download failure of the INT8 DLL due to offline environments or DNS issues.
  - *Mitigation*: Catch exceptions, log warnings to standard output, and continue the OptiScaler setup process.
