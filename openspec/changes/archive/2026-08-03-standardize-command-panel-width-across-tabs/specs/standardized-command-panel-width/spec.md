## Purpose

Defines requirements for standardizing the horizontal width and right margin of the Steam launch command panel (`commandPanel`) across all navigation tabs in GOverlay.

## ADDED Requirements

### Requirement: Uniform Command Panel Width Across Tabs
GOverlay SHALL maintain a consistent right-margin alignment for `commandPanel` across all navigation tabs, ensuring the launch command box has the exact same horizontal width on OptiScaler and EnvVars tabs as it does on MangoHud, vkBasalt, vkSumi, and Games tabs.

#### Scenario: Navigating to OptiScaler or EnvVars tab
- **WHEN** the user navigates to the OptiScaler (Upscalers) or EnvVars (Tweaks) tab where bottom bar action buttons are hidden
- **THEN** GOverlay SHALL adjust `commandPanel` right anchoring to `goverlaybarPanel` with a right margin of `153px`, matching the right boundary of tabs with visible action buttons.

#### Scenario: Navigating to MangoHud, vkBasalt, vkSumi, or Games tab
- **WHEN** the user navigates to the MangoHud, vkBasalt, vkSumi, or Games tab where bottom bar action buttons are visible
- **THEN** GOverlay SHALL anchor `commandPanel` right to `FPreviewBtn` with a right margin of `6px`.
