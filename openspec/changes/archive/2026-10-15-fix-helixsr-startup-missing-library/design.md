# Design: HelixSR Startup Verification & OptiScaler Companion Synchronization

## Context
See `proposal.md` for background. HelixSR provides DLSS Model E neural upscaling on AMD hardware. Upstream v1.9.0 separated the FSR drop-in / shader compiler from OptiScaler (`HelixSR-Scaler`). In GOverlay, `CheckAndInstallHelixSR` and `GetMissingOptiScalerComponents` assumed `optiscaler/OptiScaler.dll` was always provided within the downloaded archive, causing GOverlay to treat valid v1.9.0 installations and compiled runtimes as broken.

## Goals / Non-Goals

**Goals:**
- Recognize `amd_fidelityfx_dx12.dll` and `helixsr-setup.sh` as the essential runtime components of HelixSR.
- Synchronize missing `optiscaler/OptiScaler.dll` and `optiscaler/fakenvapi.*` from `optiscaler-stable` into `optiscaler-helixsr/optiscaler/` automatically.
- Prevent startup self-healing routines from overwriting compiled shaders (`IsHelixSRCompiled`).
- Eliminate the spurious startup warning notification while maintaining offline resilience.

**Non-Goals:**
- Integrating multi-archive downloads from `HelixSR-Scaler` (inheriting from the pre-verified stable OptiScaler cache is cleaner, faster, and self-contained).
- Modifying the on-demand shader compilation pipeline (`CompileHelixSR`).

## Decisions

### Decision 1: Primary Runtime Identification
In `GetMissingOptiScalerComponents` and `CheckAndInstallHelixSR`, verify that `amd_fidelityfx_dx12.dll` exists in `GetBGModOriginalHelixSRPath`. If `amd_fidelityfx_dx12.dll` exists and `IsHelixSRCompiled` is true, the runtime is completely satisfied.
- *Alternative Considered*: Download `HelixSR-Scaler` from its separate GitHub repo.
- *Rationale*: OptiScaler is already downloaded and maintained in `optiscaler-stable`. Re-using the tested stable OptiScaler binaries avoids an extra GitHub API call and redundant ~130MB download.

### Decision 2: Automatic Companion Seeding from Stable OptiScaler
In `CheckAndInstallHelixSR`, after extraction or during verification:
If `TargetDir + 'optiscaler' + PathDelim + 'OptiScaler.dll'` does not exist, copy `OptiScaler.dll`, `fakenvapi.dll`, and `fakenvapi.ini` from `GetBGModOriginalPath` into `TargetDir + 'optiscaler' + PathDelim`.
- *Alternative Considered*: Remove OptiScaler deployment entirely from HelixSR.
- *Rationale*: Users can choose between standard OptiScaler backend and experimental Native DLSS mode for HelixSR in GOverlay. Having the companion files in place ensures both modes work seamlessly.

### Decision 3: Skip Re-download when Shaders are Compiled
If `FileExists(Dx12Dll)` and `IsHelixSRCompiled(TargetDir)` is true, `CheckAndInstallHelixSR` will skip downloading and exit with `True`, preventing accidental loss of compiled weights.

## Risks / Trade-offs

- **[Risk]** `optiscaler-stable` cache might not be downloaded yet when HelixSR is checked.
  - *Mitigation*: In `CheckAndInstallMandatoryLibraries`, `CheckAndInstallOptiScaler` runs first (0% - 30%), ensuring `optiscaler-stable` is already populated before `CheckAndInstallHelixSR` runs.
- **[Risk]** Upstream HelixSR changes internal file locations again in a future version.
  - *Mitigation*: `CopyDirectoryTree` continues to handle root-level or subfolder-level extractions dynamically.
