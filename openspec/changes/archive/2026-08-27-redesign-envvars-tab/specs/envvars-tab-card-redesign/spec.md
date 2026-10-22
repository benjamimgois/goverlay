## Purpose

Provides a clean, card-based interface with refined toggle controls for managing environment variables and Proton/Wine compatibility tweaks in GOverlay.

## ADDED Requirements

### Requirement: Card-Based Grouped Layout for EnvVars
The EnvVars tab SHALL organize environment variables and tweaks into distinct themed cards (`General`, `Graphics`, `Performance`, `Latency reduction`, and `Custom Variables`) using the standard GOverlay card background and border styling.

#### Scenario: Viewing EnvVars tab categories
- **WHEN** the user navigates to the EnvVars tab
- **THEN** the settings are displayed within structured dark cards with clear, non-intrusive category headers rather than full-width saturated blue banners.

### Requirement: Refined Toggle Switches
The EnvVars tab SHALL provide refined toggle switches for enabling and disabling environment variables, matching the application dark theme palette and visual state conventions.

#### Scenario: Toggling a variable switch
- **WHEN** the user clicks on a tweak or variable item row or its toggle switch
- **THEN** the switch state transitions between enabled and disabled with smooth visual feedback, and the underlying configuration is updated.

### Requirement: Compact Badge Chips for Special Prefixes
The EnvVars tab SHALL display compatibility tags (such as `[CachyOS]`, `[MESA]`, and `[LowLatency]`) as compact, rounded badge chips alongside the tweak description.

#### Scenario: Rendering items with vendor or layer tags
- **WHEN** an environment variable option has an associated prefix or tag
- **THEN** the tag is rendered as a clean badge chip distinct from the main descriptive label.

### Requirement: Scroll Safety and Floating Dock Integration
The EnvVars tab SHALL preserve the global floating action dock (`[ ☰ ] [ + Add ] [ ✓ Finish ]`) while maintaining sufficient bottom padding so that no setting rows are covered when scrolled to the end.

#### Scenario: Scrolling to the bottom of the EnvVars list
- **WHEN** the user scrolls down to the end of the EnvVars tab
- **THEN** the final settings and custom variables remain fully visible and clickable above the floating dock.
