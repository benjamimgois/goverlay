# Proposal

## Why

Slides 3 (`Silicon`), 4 (`Efficiency`), 5 (`Scaling`), and 6 (`Distros`) in the PasCube results carousel suffer from heavy text clutter, redundant sub-boxes, static/hardcoded filler telemetry, and pin-label collisions, while leaving a large portion of the real 33-column `PascubeDB` dataset unused (and failing to hot-reload the background-synced `pascubedb_cache.csv`). Redesigning these four slides into clean, high-contrast visual layouts backed by real `PascubeDB` metrics makes community insights immediately digestible and authentic.

## What Changes

- **Full-Schema PascubeDB CSV Parsing & Hot-Reload Sync (`UnitCommunityInsights.pas`, `UnitPasCubeScreen.pas`)**:
  - Trigger `StartBackgroundSync` on startup/results entry and invoke `UpdateSync` during frame updates so newly downloaded `~/.cache/goverlay/pascubedb_cache.csv` automatically reloads into `TCommunityInsights`.
  - Expand `ParseCSVData` to parse full 33-column PascubeDB records (`CPU`, `GPU`, `Driver`, `Kernel`, `OS`, `Main Score`, `CPU Single`, `CPU Multi`, `GPU Score`, `Display Server`, `Desktop`, `Vulkan Driver`, `GPU Max Temp`, `CPU/GPU Max Freq MHz`, `CPU/GPU Max Power W`) and update the embedded fallback dataset.
- **Slide 3 (`3. Silicon` — Option 3A Visual Redesign)**:
  - Compute real GPU Silicon Lottery from `GPU Score` (col 11) and real CPU Silicon Lottery from `CPU Multi` (col 10) for the user's actual detected CPU model (removing the hardcoded `'Ryzen 7 7800X3D'` and removing the artificial `+5.5%` unreachable record inflation).
  - Separate spectrum bar pins (`[YOU: Score]` above the bar; `Min`, `Avg`, `Max` below the bar) to eliminate label collisions.
  - Replace the empty central void and verbose bottom verdict boxes with a **Top 4 Same-Silicon Leaderboard** in each column (showing top PascubeDB runs for the user's exact GPU and exact CPU with distro/clock tags and proportional bars).
- **Slide 4 (`4. Efficiency` — Clean Visual Redesign)**:
  - Remove the 8 static bottom telemetry sub-tiles (`1,420 RPM`, `1.185 V`, `Liquid AIO`, `VRAM Junction`), `Idle: 38 C` labels, and the bottom verdict banner (cutting text elements by more than half).
  - Present a clean 2-column layout (GPU Efficiency | CPU Efficiency) featuring a prominent thermal/power header bar (`Peak Temp`, `Headroom`, `Peak Watts`, `pts/W`) and a spacious 5-row **PascubeDB Efficiency Ranking (`pts / W`)** highlighting the user's hardware.
- **Slide 5 (`5. Scaling` — Unified Visual Scaling Ladder)**:
  - Replace the repetitive 2x3 text-heavy specification cards and bottom verdict card with a **Single Full-Width 6-Rung Visual Performance Ladder** (`PascubeDB #1 Record`, `Your System` dynamically positioned in score order, `PascubeDB Desktop Avg`, `Console / PS5 Tier`, `Handheld High Z1E`, `Steam Deck`).
  - Render thick proportional bars with clean score labels and multiplier pills (`5.6x FASTER`, `3.8x FASTER`, `BASELINE`, `% OF RECORD`) without multi-line hardware spec walls.
- **Slide 6 (`6. Distros` — Real Community Popularity & Stack Share)**:
  - Remove verbose baseline explanation sentences and hardcoded diverging delta bars (`+4.8%`, `-3.8%`).
  - Left column: Top 4 Linux distributions from `PascubeDB` with popularity bars (`%`), real average scores (`Avg: X,XXX pts`), and a `YOUR DISTRO` highlight badge.
  - Right column: Two clean visual cards computed from `PascubeDB` — **Desktop Environments** (top DE shares + average scores, highlighting the user's DE) and **Display & Graphics Stack Share** (segmented visual bars for `Wayland vs X11` and `Mesa vs NVIDIA` share + active user stack summary).

## Capabilities

### New Capabilities

### Modified Capabilities
- `pascube-community-insights`: Expand CSV parsing to full PascubeDB columns, hot-reload background sync data, and update the visual and data requirements for Slides 3 (Silicon), 4 (Efficiency), 5 (Scaling), and 6 (Distros).

## Impact

- `pascube_src/src/UnitCommunityInsights.pas`: Expanded data structures and CSV parser for CPU/GPU silicon leaderboards, real CPU model matching, efficiency rankings, scaling ladder tiers, and DE / Display Server / Driver stack shares.
- `pascube_src/src/UnitPasCubeScreen.pas`: Refactored `DrawSlide2_Silicon`, `DrawSlide3_Efficiency`, `DrawSlide4_Scaling`, and `DrawSlide5_Distros`, plus `UpdateSync` integration in the update loop.
