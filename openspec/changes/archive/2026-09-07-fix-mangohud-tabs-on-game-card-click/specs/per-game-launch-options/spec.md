## ADDED Requirements

### Requirement: MangoHud tab visibility restoration on game card selection
The system SHALL restore visibility for all MangoHud configuration tabs when a user clicks on a game card on the Games tab, ensuring the tab bar is rendered even if other overlay modules were previously visited.

#### Scenario: User navigates from other tools to game card
- **WHEN** user visits another tool tab that hides MangoHud tabs (such as Post processing or Upscalers)
- **WHEN** user returns to the Games tab and clicks on any game card
- **THEN** all MangoHud configuration tabs (`presetTabSheet`, `visualTabSheet`, `performanceTabSheet`, `metricsTabSheet`, `extrasTabSheet`) become visible (`TabVisible = True`)
- **THEN** unrelated tool tabs (`vkbasaltTabSheet`, `vksumiTabSheet`, `optiscalerTabSheet`, `losslessScalingTabSheet`, `tweaksTabSheet`, `gamesTabSheet`, `FHomeTabSheet`) are hidden (`TabVisible = False`)
- **THEN** the main tab bar displays the MangoHud tabs with the Presets tab active
