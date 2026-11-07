# Design

## Context

See `proposal.md` for motivation. PasCube renders its 6-slide post-benchmark results carousel using immediate-mode SDF text and box primitives in `TTextOverlay` (`UnitTextOverlay.pas`) at a virtual `1920x1080` canvas resolution inside `UnitPasCubeScreen.pas`. Community statistics are parsed from `~/.cache/goverlay/pascubedb_cache.csv` (or `FALLBACK_COMMUNITY_CSV`) by `TCommunityInsights` (`UnitCommunityInsights.pas`).

Currently:
1. `TCommunityInsights.ParseCSVData` only reads columns `0` (`user`), `3` (`gpu`), `7` (`os`), and `8` (`mainScore`), ignoring the remaining 29 columns present in the live Google Sheet (`CPU`, `CPU Single`, `CPU Multi`, `GPU Score`, `Display Server`, `Desktop`, `Vulkan Driver`, `GPU Max Temp`, `CPU/GPU Max Freq MHz`, `CPU/GPU Max Power W`).
2. `UpdateSync` is never called during the render/update loop, and `UpdateSync` does not trigger a re-parse when `TCommunitySyncThread` finishes downloading the CSV.
3. Slides 3, 4, 5, and 6 suffer from visual imbalances:
   - Slide 3 (`DrawSlide2_Silicon`) has a large empty void in the center of both columns, overlapping spectrum pin labels (`YOU` vs `RECORD`), an artificially inflated GPU record (`Round(GPUScoreForModel * 1.055)`), and a hardcoded `'Ryzen 7 7800X3D'` CPU model.
   - Slide 4 (`DrawSlide3_Efficiency`) crams 27 boxes and 65+ text strings onto the screen, including 8 hardcoded telemetry sub-tiles (`1,420 RPM`, `1.185 V`, `Liquid AIO`, `VRAM Junction`) and a redundant bottom verdict bar.
   - Slide 5 (`DrawSlide4_Scaling`) renders 6 repetitive specification cards in a 2x3 grid where handheld bars are scaled against `8,062` without visually anchoring the user's rig on the same scale.
   - Slide 6 (`DrawSlide5_Distros`) crams 3 verbose baseline-delta cards on the right column with hardcoded percentages and explanatory sentences.

## Goals / Non-Goals

**Goals:**
- Parse full 33-column PasCubeDB CSV data in `UnitCommunityInsights.pas` and automatically hot-reload when `TCommunitySyncThread` completes.
- Redesign Slides 3, 4, 5, and 6 in `UnitPasCubeScreen.pas` to maximize visual clarity, negative space, and real PasCubeDB data representation.
- Eliminate all pin/text collisions and hardcoded fake telemetry tiles.

**Non-Goals:**
- Changing the 3D Vulkan benchmark rendering passes, scoring formulas, or Slides 1 (`Overview`) and 2 (`Curve`).
- Adding external UI dependencies or new font textures (all visuals use `TTextOverlay.AddBox` and `TTextOverlay.AddText`).

## Decisions

### 1. Full-Schema PasCubeDB Parsing & Hot-Reload Sync (`UnitCommunityInsights.pas`)
- **Decision**: Extend `TCommunityInsights` to pass `aUserCPU: string` (from `GetCPUName`) and parse columns:
  - `Col 1`: `CPU` (normalized via a helper `ExtractCPUChipToken` / `CleanCPUName` matching Ryzen, Core i3/i5/i7/i9/Ultra, Steam Deck, Z1 Extreme, Apple/ARM, etc.)
  - `Col 3`: `GPU`
  - `Col 5`: `Driver` (Mesa / NVIDIA)
  - `Col 6`: `Kernel`
  - `Col 7`: `Operating System`
  - `Col 8`: `Main Score`
  - `Col 9`: `CPU Single`
  - `Col 10`: `CPU Multi`
  - `Col 11`: `GPU Score`
  - `Col 18`: `Display Server` (`Wayland` / `X11`)
  - `Col 19`: `Desktop` (`KDE Plasma`, `GNOME`, `Hyprland`, `Gamescope`, `Cinnamon`, `XFCE`, etc.)
  - `Col 27`: `CPU Max Freq (MHz)`
  - `Col 28`: `GPU Max Freq (MHz)`
  - `Col 29`: `CPU Max Power (W)`
  - `Col 30`: `GPU Max Power (W)`
- **Hot-Reload Mechanism**: When `TCommunitySyncThread` finishes with `FSuccess = True`, `TCommunityInsights.UpdateSync` sets `FLoaded := False` and re-invokes `EnsureLoaded` with the cached user benchmark parameters so the active carousel immediately reflects the live database count and metrics.
- **Rationale**: Fixes the bug where `49 Samples Recorded` (from the fallback string) was shown even when online, and unlocks real CPU silicon binning, real desktop environment share, and Wayland/Mesa stack ratios.

### 2. Slide 3 (`DrawSlide2_Silicon`) — Option 3A: Anti-Collision Spectrum + Top 4 Same-Silicon Leaderboard
- **Decision**:
  - **Real Component Matching**: Filter GPU submissions matching `ExtractGPUChipToken(aUserGPU)` using column 11 (`GPU Score`, falling back to `Main Score` if missing) and filter CPU submissions matching `ExtractCPUChipToken(aUserCPU)` using column 10 (`CPU Multi`). Remove the `Round(Score * 1.055)` artificial record inflation so `ModelMax` is the true highest score among matching samples (including the user's run).
  - **Anti-Collision Spectrum Bar**: Render `[YOU: X,XXX]` callout pill **above** the spectrum bar (`barY - 2.1 * charHeight`) and render `Min: X,XXX`, `Avg: X,XXX`, and `Max: X,XXX` **below** the spectrum bar (`barY + 0.9 * charHeight`), with a single clean `Delta vs Model Avg` badge above the leaderboard.
  - **Top 4 Same-Silicon Leaderboard**: Use the lower half of both the GPU and CPU columns to render up to 4 horizontal comparison rows (`Leaderboard[0..3]`) from `PasCubeDB` for that exact GPU/CPU model, showing `#Rank`, Distro / Clock (`MHz` when available), proportional bar, and score, highlighting the user's row in Cyan/Gold.

### 3. Slide 4 (`DrawSlide3_Efficiency`) — Clean Thermal Header + 5-Row PasCubeDB Efficiency Ranking
- **Decision**:
  - Remove the 8 bottom telemetry sub-boxes (`Hotspot Delta`, `Fan Profile`, `Power Budget`, `VRAM Junction`, `CCD0 Core Temp`, `VDDCR Core`, `Package Power`, `Cooling Profile`), the `Idle: 38 C / 44 C` labels, and the bottom verdict banner.
  - Keep the 3 top KPI summary cards (`GPU Efficiency`, `CPU Efficiency`, `Overall System Efficiency`).
  - Inside each column (Left: GPU | Right: CPU):
    1. **Clean Thermal & Power Header**: Displays Peak Temperature (`66°C`), Thermal Headroom (`+24°C Headroom`), Peak Power (`220W`), and a clean horizontal thermal gauge bar (`gpuTemp / 90°C` and `cpuTemp / 95°C`).
    2. **PasCubeDB Efficiency Spectrum (`pts / W`)**: 5 tall, well-spaced horizontal bar cards (`itemH = 2.2 * charHeight` with generous vertical gap) comparing the user's component efficiency (`pts/W`) against top/representative GPU and CPU architectures in `PasCubeDB`, dynamically sorted by `pts/W` so the user's bar sits in its true rank position.

### 4. Slide 5 (`DrawSlide4_Scaling`) — Unified 6-Rung Visual Performance Ladder
- **Decision**:
  - Replace the 2x3 grid of text-heavy cards and the bottom verdict banner with a single full-width container holding **6 horizontal ladder rungs** sorted descending by score:
    1. `PasCubeDB #1 Record` (top community submission specs + score, e.g. `8,062 pts`)
    2. `PasCubeDB Desktop Avg` (computed mean of desktop runs, e.g. `~3,420 pts`)
    3. `Console Tier (PlayStation 5)` (`1,800 pts`)
    4. `Gaming Notebook / Mobile Avg` (or `Handheld High — ROG Ally X / Z1E`, `1,212 pts`)
    5. `Steam Deck (Valve VanGogh)` (`818 pts`)
    6. Plus `★ YOUR SYSTEM (<GPU/CPU>)` dynamically inserted into its exact rank order among the 6 rungs!
  - Each rung displays:
    - Left: Tier Title + concise subtitle (1 short line)
    - Center: Thick proportional progress bar (`barH = 18px`) scaled against the top rung (`#1 Record`), with a vertical reference marker at the user's score X-coordinate so the user can visually compare every bar against their own system.
    - Right: Score (`X,XXX pts`) + high-contrast Multiplier Badge (`5.6x FASTER`, `3.8x FASTER`, `1.3x FASTER`, `YOUR BASELINE`, or `57% OF #1`).

### 5. Slide 6 (`DrawSlide5_Distros`) — Community Popularity & Software Stack Share
- **Decision**:
  - **Left Column (Top 4 Distros in PasCubeDB)**: Render up to 4 spacious horizontal cards for the most popular Linux distributions in `PasCubeDB`, each with `#Rank`, Distro Name, `YOUR DISTRO` pill (on match), percentage share (`XX.X%`), thick progress bar, and `Avg Score: X,XXX pts` (`N runs`).
  - **Right Column (2 Clean Ecosystem Cards)**:
    - **Card 1 — Desktop Environments (PasCubeDB)**: Top 4 Desktop Environments aggregated from column 19 (`KDE Plasma`, `GNOME`, `Hyprland`, `Gamescope/Other`) with percentage bars, average scores, and highlight on the user's active DE.
    - **Card 2 — Display Protocol & Graphics Stack Share**: Two clean segmented comparison bars aggregated from columns 18 (`Wayland` vs `X11` share %) and 5/21 (`Mesa RADV/ANV` vs `NVIDIA` share %), plus a clean one-line pill at the bottom of the card showing the user's active stack (`Your Stack: <DE> · <Wayland/X11> · <Driver> · Kernel <Ver>`).

## Risks / Trade-offs

- **[Risk] Sparse telemetry columns in older CSV rows** → **Mitigation**: Older rows in `PasCubeDB` may have empty `Desktop`, `Display Server`, or `Power` columns. Aggregation counters for DE, Display Server, and Power Efficiency only count non-empty valid rows and fall back to sensible community baselines when fewer than 3 valid rows exist for a metric.
- **[Risk] Long GPU/CPU/Distro strings overflowing column bounds** → **Mitigation**: Truncate or normalize hardware and software labels (`CleanGPUName`, `CleanCPUName`, `NormalizeDistroName`) and size progress bar tracks with explicit right-side margins for score/multiplier badges.
