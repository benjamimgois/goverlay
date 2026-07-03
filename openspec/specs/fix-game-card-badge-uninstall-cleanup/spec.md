# fix-game-card-badge-uninstall-cleanup

## Purpose
Ensures that clicking "Uninstall changes" on a game card only removes the GOverlay configuration badge (top-right) while preserving the platform badge (Steam/Wine icon, top-left).

## Requirements
### Requirement: Game card platform badge is preserved on uninstall
When the user clicks "Uninstall changes" on a game card, GOverlay SHALL remove only the GOverlay settings badge (top-right corner, indicating active configurations) and SHALL preserve the Steam/Heroic platform badge (top-left corner, indicating the game's platform origin). The GOverlay badge and platform badge SHALL be distinguished at creation time via their `Tag` property so the cleanup loop can target the correct badge.

#### Scenario: Uninstalling changes on a Steam game card
- **WHEN** the user clicks "Uninstall changes" on a Steam game card that has both a Steam icon badge (top-left) and a GOverlay badge (top-right)
- **THEN** the GOverlay badge is removed from the card and the Steam icon badge remains visible.

#### Scenario: Uninstalling changes on a non-Steam game card
- **WHEN** the user clicks "Uninstall changes" on a non-Steam game card with a Wine/Heroic icon badge and a GOverlay badge
- **THEN** the GOverlay badge is removed and the Wine/Heroic icon badge remains visible.