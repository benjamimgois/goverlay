# Design

## Context

See `proposal.md - Why`. With the unification of the Post processing tab under `reshadeTabSheet`, `vkbasaltTabSheet` is hidden (`TabVisible := False`) and never triggers `vkbasaltTabSheetShow`. Consequently, vkBasalt shaders in `~/.config/vkBasalt/reshade-shaders/` are not checked or downloaded on first run, causing the vkBasalt effects list to remain blank.

## Goals / Non-Goals

**Goals:**
- Include `~/.config/vkBasalt/reshade-shaders` in `HasMissingMandatoryLibraries`.
- Add `CheckAndInstallVkBasaltShaders` in `optiscaler_update.pas` and call it from `TStartupDownloadThread.Execute`.
- Report download progress on the startup splash screen in the 95%–99% bracket.
- Populate `aveffectsListbox` upon completion and ensure UI repaints.

**Non-Goals:**
- Changing user's customized shader files if `reshade-shaders` already exists.

## Decisions

### 1. Download method for vkBasalt Shaders
- **Decision**: Download the tarball from GitHub (`https://github.com/benjamimgois/reshade-shaders/archive/refs/heads/master.tar.gz`) via `RunCurlWithProgress` and extract with `ExtractTarArchive(TempTar, DestDir, 1)` or fallback to git if needed.
- **Rationale**: Downloading the tarball via curl is significantly faster, lightweight, and completely headless compared to git clone, while fitting seamlessly into `RunCurlWithProgress` splash progress reporting.
- **Alternatives Considered**: Using `git clone`. Git clone requires git or libgit2 runtime and doesn't integrate natively into `RunCurlWithProgress` bracket scaling on the startup thread.

### 2. Progress Bracket on Startup Splash
- **Decision**:
  - ReShade Runtime & Standard Shaders: 90% – 95%
  - vkBasalt ReShade Shaders: 95% – 99%
  - Finish: 100%
- **Rationale**: Gives smooth, visible feedback for both ReShade and vkBasalt shader packs without jumpy progress bar jumps.

### 3. Fault Tolerance
- **Decision**: If vkBasalt shaders download fails, record `'vkBasalt Shaders'` in `AFailedFiles` so `TStartupDownloadThread` doesn't abort startup and reports the failure via toast upon main window show.

## Risks / Trade-offs

- *[Risk]* GitHub tarball branch name change (e.g. `main` vs `master`).
  - *Mitigation*: Verified `https://github.com/benjamimgois/reshade-shaders/archive/refs/heads/master.tar.gz` returns HTTP 302 / tar.gz successfully.
