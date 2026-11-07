# Proposal

## Why

Following the successful deployment of the initial 4-slide results carousel in PasCube, user testing demonstrated high engagement with community-driven insights. However, enthusiast gamers on Linux seek deeper hardware-level validation:
1. Knowing how their exact GPU die performs against identical silicon samples ("Silicon Lottery").
2. Understanding their power efficiency (points per Watt) and thermal dissipation headroom.
3. Celebrating their benchmark milestones through gamified achievement cards and badges.
4. Aligning the hardware scaling slide with realistic reference systems (High-End PC, Mid-Range PC, and PlayStation 5 Base alongside Handhelds).

Expanding the results carousel to 7 dedicated slides elevates PasCube into a premier enthusiast hardware profiling suite for Linux gaming.

## What Changes

- **7-Slide Results Carousel**:
  - Re-order and expand the carousel into 7 slides:
    1. `Overview` (Main score, sub-scores, live telemetry, score trend chart, and expandable hardware specifications accordion).
    2. `Curve` (Global PasCubeDB normal distribution bell curve with high-contrast amber/gold needle for user score).
    3. `Silicon` (Silicon Lottery: die dispersion spectrum bar + same-GPU leaderboard ranking for identical GPU models).
    4. `Efficiency` (Thermal & Power Efficiency: Points/Watt index, GPU/CPU thermal headroom gauges, and zero-throttling verdict).
    5. `Scaling` (Hardware Performance Scaling: Handheld Consoles [Steam Deck, ROG Ally X, Switch 2] vs. Desktops & Consoles [High-End PC, Mid-Range PC, PlayStation 5 Base]).
    6. `Distros` (Linux OS Ecosystem: top distributions for user GPU architecture, segmented family share, and performance advantage).
    7. `Badges` (Community Achievements & Gamification: 3x2 cyber card grid of unlocked and locked milestone badges).
- **Navigation & Autoplay**:
  - Update top header navigation bar to host 7 compact pill buttons (`1. Overview` through `7. Badges`).
  - Seamless autoplay progress timer (6s per slide) with pause on mouse hover, left/right cyber arrow buttons, and keyboard arrow navigation.
- **Strict English Localization**:
  - Ensure 100% of labels, tooltips, metrics, and verbiage are formatted strictly in English across all 7 slides.

## Capabilities

### Modified Capabilities
- `pascube-community-insights`: Extended to compute same-GPU model silicon ranking and dispersion statistics, power efficiency index (pts/W), thermal headroom limits, updated reference targets (High-End, Mid-Range, PS5 Base), and evaluation of gamified achievement badges.

## Impact
- **PasCube Render Engine & UI**: `UnitPasCubeScreen.pas` carousel renderer, hit-testing, input handling, and slide animation state machine.
- **Community Analytics Engine**: `UnitCommunityInsights.pas` data calculations (silicon dispersion, thermal efficiency, badge unlocks, scaling targets).
- **Dependencies**: No external library dependencies; renders natively via Pascal/Vulkan software/pipeline draw commands matching existing Goverlay cyber styling.
