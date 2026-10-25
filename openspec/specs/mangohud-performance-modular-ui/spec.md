# mangohud-performance-modular-ui Specification

## Purpose
Defines the modular 3-card architecture, responsive scrollbox container, and balanced sub-card layout of the Goverlay Performance tab.

## Requirements

### Requirement: Three Master Cards Architecture
The system SHALL organize the Goverlay Performance tab into three thematic master cards arranged vertically: Rate Control & Synchronization (Card 1, top), Telemetry & HUD Graphics (Card 2, middle), and Energy Saving & Visual Optimization (Card 3, bottom).

#### Scenario: Navigating to the Performance tab
- **WHEN** the user navigates to the Performance tab
- **THEN** the system SHALL display three primary cards in vertical order: Rate Control & Synchronization on top, Telemetry & HUD Graphics in the middle, and Energy Saving & Visual Optimization at the bottom

### Requirement: Symmetrical Sub-Card Layout
The system SHALL present related controls within each master card split into two equal-width sub-cards styled with uniform background fill and subtle borders.

#### Scenario: Inspecting Rate Control & Synchronization sub-cards
- **WHEN** the user views the Rate Control & Synchronization card
- **THEN** the left sub-card SHALL contain the MangoHud FPS Limiter controls and the right sub-card SHALL contain the VSYNC synchronization selectors

#### Scenario: Inspecting Telemetry & HUD Graphics sub-cards
- **WHEN** the user views the Telemetry & HUD Graphics card
- **THEN** the left sub-card SHALL contain Frame Rate Display metrics and the right sub-card SHALL contain Frame Timing and Plot controls

#### Scenario: Inspecting Energy Saving & Visual Optimization sub-cards
- **WHEN** the user views the Energy Saving & Visual Optimization card
- **THEN** the left sub-card SHALL contain the vkNemu Idle Limiter with its state flow visualization and the right sub-card SHALL contain Texture and Mipmap LOD Filters

### Requirement: Responsive Scroll Container
The system SHALL host all Performance tab cards inside a modern TScrollBox container with a seamless background wrapper and dynamic reflow that adapts to window resizing without clipping controls.

#### Scenario: Resizing the Goverlay application window
- **WHEN** the user resizes the Goverlay window while on the Performance tab
- **THEN** the cards and their sub-cards SHALL reflow symmetrically and allow vertical scrolling if the content exceeds the visible viewport
