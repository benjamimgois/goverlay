## Context

In `games_tab.pas`, game card rendering logic (`LoadSteamGames` and `LoadNonSteamFolders`) checks bitmask flags for `HasMango`, `HasVkBasalt`, `HasOptiScaler`, and `HasTweaks`. When `BadgeCount > 0`, it currently constructs a graphite rectangle (`TShape` tagged as `BdgBg`) and loops through each active bitmask to instantiate separate `TImage` or `TLabel` controls on the right side of the card.

## Goals / Non-Goals

**Goals:**
- Replace the graphite background strip (`TShape`) and multi-icon loop with a single transparent `TImage` badge using the GOverlay app icon (`goverlay.png`).
- Format a clean, human-readable tooltip listing all active custom configurations (e.g., "Configurações ativas: MangoHud, OptiScaler") in Portuguese.

**Non-Goals:**
- Modifying the underlying config file detection logic (`HasMango`, `HasVkBasalt`, `HasOptiScaler`, `HasTweaks`).
- Changing badge logic for the Add Folder card (`Tag = 9998`).

## Decisions

### Decision 1: Single TImage component for GOverlay badge
Instead of looping over `BdgBit` (0..3) and instantiating multiple controls, instantiate a single `TImage` placed at `(CARD_W - 20, 4, 16, 16)` with `Transparent := True`.
- **Rationale**: Removes visual clutter, eliminates component proliferation, and restores clean card aesthetics.

### Decision 2: Dynamic Hint construction
Concatenate active configuration names into a comma-separated string assigned to `BdgImg.Hint` and `BdgImg.ShowHint := True`.
- **Rationale**: Preserves full transparency about active tweaks without needing individual icons for each mod.

## Risks / Trade-offs

- [Risk] Missing GOverlay icon asset at runtime → Mitigation: Fall back to existing icon path or default asset check (`GetAppBaseDir + 'assets/icons/goverlay.png'`).
