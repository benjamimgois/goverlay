## Purpose

Defines requirements for displaying all preferred upscaler dropdown items in lowercase to match GOverlay UI conventions.

## ADDED Requirements

### Requirement: Lowercase Preferred Upscaler Items
GOverlay SHALL display all dropdown options in `preferredUpscalerComboBox` in lowercase strings (`auto`, `xess`, `fsr21`, `fsr22`, `fsr4`, `dlss`).

#### Scenario: Inspecting preferred upscaler dropdown items
- **WHEN** the user opens or views the "Preferred upscaler" dropdown on the OptiScaler tab
- **THEN** all item labels SHALL be formatted in lowercase (`auto`, `xess`, `fsr21`, `fsr22`, `fsr4`, `dlss`).
