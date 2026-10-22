# Proposal: Robust Wine/Proton Fallback and Prefix Cleaning for HelixSR Compilation

## Why

When users activate the HelixSR upscaler method on distributions such as CachyOS or Arch Linux, neural shader compilation frequently crashes with Wine error `c0000135` (`STATUS_DLL_NOT_FOUND`: `could not open working directory "C:\windows\system32\"`, `could not load kernel32.dll`). This happens because the upstream `helixsr-setup.sh` indiscriminately selects the first matching executable found under `steamapps/common/Proton*/files/bin/wine` (which in CachyOS or newer setups resolves to `Proton 11.0` or container-dependent Proton-SLR builds that cannot initialize a standalone Wine prefix on the host), and leaves behind corrupted temporary prefixes in `~/.local/share/HelixSR/wineprefix` without validation or fallback to system `wine` or stable Proton versions (e.g. Proton 9 / Proton-GE).

Implementing robust runtime discovery, proactive temporary prefix cleansing, and fallback to verified Wine/Proton candidates in GOverlay ensures reliable on-demand neural shader compilation across diverse Linux setups.

## What Changes

- **Pre-compilation Prefix Cleanup**: Before executing the HelixSR compilation script, GOverlay will ensure any stale or corrupted temporary prefix directory (`~/.local/share/HelixSR/wineprefix`) is removed to prevent corrupted prefix re-use errors.
- **Robust Wine/Proton Discovery and Validation**: GOverlay will inspect and provide an environment or wrapper that verifies Wine runtime viability (validating execution and prefix bootstrap capability) across system `wine` (`/usr/bin/wine`), Proton-GE, stable official Proton builds (Proton 9.0 / Experimental), before falling back to unverified Proton candidates.
- **Failure Diagnostics and Informative Feedback**: When compilation fails due to Wine or shader compiler execution errors, GOverlay will capture the relevant failure detail and present an actionable toast notification directing the user to verify system Wine or compatible Proton versions.

## Capabilities

### Modified Capabilities
- `helixsr-runtime-management`: Extend the "On-Demand Neural Shader Compilation" requirement to require pre-compilation prefix cleanliness, runtime verification of Wine/Proton compatibility before shader compilation, and resilient fallback when a selected compatibility tool fails to initialize.

## Impact

- **Affected code**: `optiscaler_update.pas` (in `CompileHelixSR` and helper runtime resolution functions) and `overlayunit.pas` (compilation feedback handling).
- **Dependencies**: No new external dependencies; leverages existing Wine/Proton installations on the host system.
