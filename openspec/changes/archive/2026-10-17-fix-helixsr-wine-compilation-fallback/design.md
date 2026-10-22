# Design: Robust Wine/Proton Fallback and Prefix Cleaning for HelixSR Compilation

## Context

See `proposal.md` for motivation. Currently, `CompileHelixSR` in `optiscaler_update.pas` executes `helixsr-setup.sh --yes < /dev/null` in `~/.local/share/goverlay/optiscaler-helixsr/`.

`helixsr-setup.sh` discovers a Wine/Proton binary by checking `$HOME/.local/share/Steam/steamapps/common/Proton*/files/bin/wine` and selecting the first matching path via shell glob without execution validation. In systems like CachyOS or newer Arch setups with `Proton 11.0` or container-dependent Proton-SLR builds, executing `files/bin/wine` directly from the host fails during prefix initialization with Wine status `c0000135` (`STATUS_DLL_NOT_FOUND` on `kernel32.dll`). Furthermore, failed runs leave behind a corrupt `~/.local/share/HelixSR/wineprefix` directory that breaks any subsequent compilation attempts.

## Goals / Non-Goals

**Goals:**
- Guarantee that `~/.local/share/HelixSR/wineprefix` is proactively removed before compilation starts so stale prefixes never cause false-positive failures.
- Implement robust Wine candidate discovery and validation that tests candidates (verifying executable health and basic prefix bootstrapping) and prioritizes native system `wine` (`/usr/bin/wine`) or stable Proton-GE / official Proton builds over unverified versions.
- Provide clear diagnostic logs and toast feedback when Wine/Proton execution fails during shader compilation.

**Non-Goals:**
- Modifying upstream HLSL neural network kernels or the neural model synthesis code.
- Altering the user's Steam library or modifying system-level Proton installations.

## Decisions

### Decision 1: Proactive Cleanup of Temporary Wineprefix
- **Choice**: In `CompileHelixSR` before spawning `helixsr-setup.sh`, delete `~/.local/share/HelixSR/wineprefix` if it exists.
- **Rationale**: `helixsr-setup.sh` only cleans the prefix at the very end of a successful run. A previous interrupted run leaves an empty or corrupt prefix, causing Wine to fail on `C:\windows\system32\`. Proactive cleanup guarantees clean state.
- **Alternatives Considered**: Cleaning up only on error; rejected because it does not fix states left by external kills or previous crashes.

### Decision 2: Sanitized Wine Discovery and Validation
- **Choice**: Ensure `helixsr-setup.sh` selects a validated Wine runtime. GOverlay will sanitize the discovery logic or supply a validated Wine binary candidate by testing execution (e.g. `"$WINE" --version` and prefix validation), prioritizing native `/usr/bin/wine` when present and working, followed by verified Proton builds.
- **Rationale**: Native system Wine on Arch/CachyOS avoids Steam Linux Runtime (SLR) container dependencies and executes cleanly on the host OS. Testing candidates before generating `dxc-wine.sh` prevents getting trapped by an experimental or incomplete `Proton 11.0` folder.
- **Alternatives Considered**: Forcing Proton only; rejected because Proton SLR builds are designed for container execution and can fail on host.

### Decision 3: Specific Error Diagnostics in UI
- **Choice**: Track setup script output lines specifically for Wine/DXC failure signatures (e.g. `could not load kernel32.dll`, `dxc-wine.sh` failure, or missing Wine/Proton) to display a targeted toast notification advising the user to install system `wine` (`sudo pacman -S wine`) or check their Proton compatibility tool.
- **Rationale**: Greatly improves user experience and avoids confusing developers with generic failure reports.

## Risks / Trade-offs

- **[Risk] Neither system Wine nor a compatible Proton version is installed**:
  - *Mitigation*: The error notification and terminal log will clearly explain that no compatible Wine/Proton runtime was found to execute the Microsoft DXC shader compiler, with direct command instructions for the user's distribution.
- **[Risk] Upstream release updates may re-extract `helixsr-setup.sh`**:
  - *Mitigation*: The cleanup and wrapper/environment validation is handled cleanly in GOverlay's compilation orchestration in `optiscaler_update.pas`.
