## Context

GOverlay's sidebar navigation displays 5 items: Games (0), MangoHud (1), Post processing (2), OptiScaler (3), and EnvVars (4).
Currently, items 1 and 3 load PNG images via `TImage` (`FMangoHudImg`, `FOptiScalerImg`), while items 0, 2, and 4 use `TLabel` with Nerd Font unicode glyphs ('󰊴', '󰏘', '󰒓').
When Nerd Fonts are missing on Linux systems, font fallback fails and shows empty boxes `[ ]`.

## Goals / Non-Goals

**Goals:**
- Replace unicode font labels for Games, Post processing, and EnvVars with `TImage` controls loading PNG assets.
- Generate high-quality PNG icons for both active and inactive states in `assets/icons/`.
- Maintain exact sidebar layout, pixel dimensions, hover states, and smooth collapse/expand behavior.
- Ensure 100% font-independent visual consistency across all Linux distributions.

**Non-Goals:**
- Redesigning sidebar dimensions or navigation layout structure.
- Changing MangoHud or OptiScaler existing PNG image handling mechanisms.

## Decisions

1. **Standardize all sidebar navigation items on `TImage` components:**
   - Extend `sidebar_nav.pas` to create `TImage` instances for Games (`FGamesImg`), Post processing (`FPostProcessingImg`), and EnvVars (`FEnvVarsImg`).
   - Assign click, mouse enter, and mouse leave event handlers to image components so mouse interaction remains identical.

2. **PNG Asset Naming Convention:**
   - `games-inactive.png` & `games-active.png`
   - `postprocessing-inactive.png` & `postprocessing-active.png`
   - `envvars-inactive.png` & `envvars-active.png`
   - Preserves existing `mango-inactive.png` / `mango-active.png` and `scale-up2.png` / `scale-up2-active.png`.

3. **Active/Inactive State Updates:**
   - In `TSidebarNavHelper.SetNavActive`, iterate over items and update image sources for active item (`active.png`) and inactive items (`inactive.png`).

## Risks / Trade-offs

- [Missing asset file] → Fallback to empty image container gracefully with warning logged to `StdErr` without crashing the application.
- [Asset resolution] → High DPI assets (48x48px rendered in 24x24px container with `Stretch = True` and `Proportional = True`) guarantee crisp rendering on High-DPI screens.
