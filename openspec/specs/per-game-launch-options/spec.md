## Purpose

Ensures that selecting a game card immediately updates and synchronizes the generated launch command for that specific game across the entire UI and dialogs.

## Requirements

### Requirement: Immediate launch command update on game card selection
The system SHALL recompute the active launch command immediately when a user clicks on a game card on the Games tab.

#### Scenario: User clicks game card and opens Finish dialog
- **WHEN** user clicks on a game card on the Games tab
- **THEN** system sets the active game context and immediately updates `FLaunchCommand` to reference the selected game's `bgmod` path
- **WHEN** user immediately clicks the `[✓ Finish]` button on the floating action dock without changing any settings
- **THEN** the finish configuration dialog displays the launch command pointing to the selected game rather than `global`

### Requirement: MangoHud tab visibility restoration on game card selection
The system SHALL restore visibility for all MangoHud configuration tabs when a user clicks on a game card on the Games tab, ensuring the tab bar is rendered even if other overlay modules were previously visited.

#### Scenario: User navigates from other tools to game card
- **WHEN** user visits another tool tab that hides MangoHud tabs (such as Post processing or Upscalers)
- **WHEN** user returns to the Games tab and clicks on any game card
- **THEN** all MangoHud configuration tabs (`presetTabSheet`, `visualTabSheet`, `performanceTabSheet`, `metricsTabSheet`, `extrasTabSheet`) become visible (`TabVisible = True`)
- **THEN** unrelated tool tabs (`vkbasaltTabSheet`, `vksumiTabSheet`, `optiscalerTabSheet`, `losslessScalingTabSheet`, `tweaksTabSheet`, `gamesTabSheet`, `FHomeTabSheet`) are hidden (`TabVisible = False`)
- **THEN** the main tab bar displays the MangoHud tabs with the Presets tab active
