## 1. Badge Rendering Simplification in Steam Cards

- [x] 1.1 In `games_tab.pas` (`LoadSteamGames`), remove the graphite background strip (`BdgBg`) and multi-badge icon creation loop.
- [x] 1.2 Create a single transparent `TImage` badge using GOverlay icon at `(CARD_W - 20, 4, 16, 16)` when `BadgeCount > 0`.
- [x] 1.3 Format and assign dynamic tooltip hint showing all active configurations (MangoHud, vkBasalt, OptiScaler, Tweaks).

## 2. Badge Rendering Simplification in Non-Steam Cards

- [x] 2.1 In `games_tab.pas` (`LoadNonSteamFolders`), remove the graphite background strip (`BdgBg`) and multi-badge icon creation loop.
- [x] 2.2 Create a single transparent `TImage` badge using GOverlay icon at `(CARD_W - 20, 4, 16, 16)` when `BadgeCount > 0`.
- [x] 2.3 Format and assign dynamic tooltip hint showing all active configurations for non-Steam games.

## 3. Verification & Testing

- [x] 3.1 Verify that games with active configurations show only a single transparent GOverlay badge in the top-right corner.
- [x] 3.2 Verify that games with no active configurations display no badge.
- [x] 3.3 Verify hovering over the GOverlay badge displays the correct tooltip listing active configurations.
