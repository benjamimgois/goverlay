# Specification: Unify Tab Card Left Margins (`unify-tab-card-left-margins`)

## Requirements

### Requirement 1: Unified Left Margin Position
All content cards across all tabs (Visual, Performance, Metrics, Extras, Presets, OptiScaler, vkBasalt, Tweaks, Home) SHALL be positioned with an outer left margin of 4px relative to their parent container/scrollbox left edge.

#### Scenario: Switching between tabs maintains left alignment
- **GIVEN** the application window is open
- **WHEN** navigating between any tabs (Visual, Performance, Metrics, Presets, Extras, OptiScaler, vkBasalt, EnvVars, Home)
- **THEN** the left edge of each tab's primary cards SHALL be positioned at `Left = 4px` relative to the content area container.
