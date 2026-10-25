# Spec Delta

## MODIFIED Requirements

### Requirement: Symmetrical Sub-Card Layout
The system SHALL present related controls within each master card split into two equal-width sub-cards styled with uniform background fill and subtle borders.

#### Scenario: Inspecting Rate Control & Synchronization sub-cards
- **WHEN** the user views the Rate Control & Synchronization card
- **THEN** the left sub-card SHALL contain the MangoHud FPS Limiter controls and the right sub-card SHALL contain the VSYNC synchronization selectors

#### Scenario: Inspecting Telemetry & HUD Graphics sub-cards
- **WHEN** the user views the Telemetry & HUD Graphics card
- **THEN** the left sub-card SHALL contain Frame Rate Display metrics and FPS counter color gradient alert controls, and the right sub-card SHALL contain Frame Timing and Plot controls

#### Scenario: Inspecting Energy Saving & Visual Optimization sub-cards
- **WHEN** the user views the Energy Saving & Visual Optimization card
- **THEN** the left sub-card SHALL contain the vkNemu Idle Limiter with its state flow visualization and the right sub-card SHALL contain Texture and Mipmap LOD Filters
