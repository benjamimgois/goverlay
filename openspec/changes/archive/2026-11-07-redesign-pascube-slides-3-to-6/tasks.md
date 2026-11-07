# Tasks

## 1. PasCubeDB Data Parser & Background Sync Hot-Reload

- [x] 1.1 Update `TCommunityInsights` in `pascube_src/src/UnitCommunityInsights.pas` to accept `aUserCPU: string`, cache the user's benchmark parameters, and reload `EnsureLoaded` inside `UpdateSync` when `TCommunitySyncThread` completes, verifying that `UnitPasCubeScreen.pas` calls `UpdateSync` in the update loop and `StartBackgroundSync` on `--test-slides` and results entry.
- [x] 1.2 Expand `ParseCSVData` and `FALLBACK_COMMUNITY_CSV` in `pascube_src/src/UnitCommunityInsights.pas` to parse the full PasCubeDB columns (`CPU`, `GPU`, `Driver`, `Kernel`, `OS`, `Main Score`, `CPU Single`, `CPU Multi`, `GPU Score`, `Display Server`, `Desktop`, `CPU/GPU Max Freq MHz`, `CPU/GPU Max Power W`), computing non-inflated GPU and CPU silicon lottery stats, Top 4 GPU/CPU leaderboards, and real DE / Display Server / Driver stack shares, and verify it compiles cleanly with `lazbuild`.

## 2. Visual Redesign of Slides 3, 4, 5, and 6

- [x] 2.1 Refactor `DrawSlide2_Silicon` (Slide 3) in `pascube_src/src/UnitPasCubeScreen.pas` to implement Option 3A: render anti-collision spectrum bars (`[YOU: Score]` above the bar and `Min / Avg / Max` below the bar), remove artificial record inflation and bottom verdict boxes, and render the 4-row Same-Silicon Leaderboard in both GPU and CPU columns, verifying layout alignment on Slide 3.
- [x] 2.2 Refactor `DrawSlide3_Efficiency` (Slide 4) in `pascube_src/src/UnitPasCubeScreen.pas` to remove the 8 static bottom telemetry tiles, `Idle` labels, and bottom verdict bar, rendering a clean thermal/power header gauge and a spacious 5-row sorted PasCubeDB `pts/W` efficiency ranking in both GPU and CPU columns, verifying visual spacing on Slide 4.
- [x] 2.3 Refactor `DrawSlide4_Scaling` (Slide 5) in `pascube_src/src/UnitPasCubeScreen.pas` to replace the 2x3 specification cards with a single full-width 6-rung visual performance ladder (`PasCubeDB #1 Record`, dynamically ordered `Your System`, `PasCubeDB Desktop Avg`, `Console / PS5 Tier`, `Handheld High Z1E`, `Steam Deck`) with thick proportional bars and multiplier badges, verifying Slide 5 rendering.
- [x] 2.4 Refactor `DrawSlide5_Distros` (Slide 6) in `pascube_src/src/UnitPasCubeScreen.pas` to remove verbose baseline delta explanations and render Top 4 Distros on the left column and two clean community ecosystem cards on the right column (Desktop Environment shares and Wayland/X11 + Mesa/NVIDIA segmented stack bars + active user stack pill), verifying Slide 6 rendering.

## 3. Build & Visual Verification

- [x] 3.1 Compile `pascube_src/pascube.lpi` with `lazbuild`, copy the updated binary to `/mnt/NVME/Software/goverlay/pascube`, and verify Slides 3, 4, 5, and 6 using `--test-slides=2`, `--test-slides=3`, `--test-slides=4`, and `--test-slides=5` for clean typography, zero text collisions, and live PasCubeDB sample counts.
