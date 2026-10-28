# mangohud-extras-modular-ui Specification

## Purpose
Defines the modular sub-card presentation, balanced two-column responsive grid layout, and inline secondary control styling for system, compatibility, hardware, and benchmark options on the Goverlay Extras tab.

## Requirements

### Requirement: Thematic System and Environment Module Cards
The system SHALL group related system, compatibility, gaming, and hardware options into distinct, visually framed sub-cards arranged in a balanced two-column grid within dedicated main cards for System & Environment and Benchmarks & Logging, identified by clean, minimalist typographic headers without legacy header icons.

#### Scenario: Displaying grouped system modules
- **WHEN** the user navigates to the Extras tab
- **THEN** the system SHALL display distinct themed sub-modules:
  - Inside `System & Environment`: Platform & Display, Wine & Compatibility, Gaming & Integrations, Hardware & Session
  - Inside `Benchmarks & Logging`: Session Timings, Storage & Tools
  each framed within a modern panel with clean typography and accent badges

#### Scenario: Balanced sub-card dimensions and alignment
- **WHEN** the Extras tab content area is reflowed or resized
- **THEN** sub-cards across rows SHALL maintain uniform heights and symmetrical two-column widths without arbitrary column stretching or trailing voids

### Requirement: Inline Secondary Control and Swatch Integration
The system SHALL place secondary controls—including color indicators, configuration shortcuts, and format pills—aligned on the same baseline or inline with their parent metric toggles, rendered as distinct, proportional chips or segmented dual-pills with clear semantic tooltips.

#### Scenario: Color swatch dimensions and tooltips
- **WHEN** the user views secondary color buttons for Wine, Engine, Battery, and Media on the Extras tab
- **THEN** the color buttons SHALL render as proportional swatches of at least 20x20 pixels with distinct tooltips explaining their overlay target

#### Scenario: Temperature unit segmented pill
- **WHEN** the user inspects the temperature unit selector in Hardware & Session
- **THEN** the selector SHALL render as a compact segmented dual-pill displaying `°C` and `°F` options, toggling Fahrenheit mode when active

#### Scenario: Time configuration button placement
- **WHEN** the user views the Time metric in Platform & Display
- **THEN** the time format configuration button SHALL be rendered inline beside the Time toggle switch

### Requirement: Benchmark Logging and Storage Layout
The system SHALL organize benchmark timing sliders and storage/analysis tools into dedicated, side-by-side sub-cards within the Benchmarks & Logging card.

#### Scenario: Timing parameters presentation
- **WHEN** the user inspects the Session Timings sub-card
- **THEN** the duration, delay, and interval sliders SHALL render with clear labels and highlighted numeric value chips

#### Scenario: Storage and tools presentation
- **WHEN** the user inspects the Storage & Tools sub-card
- **THEN** the log folder path with browse button, hotkey trigger capture button, and PasPlot benchmark viewer button SHALL render with aligned baselines and uniform heights
