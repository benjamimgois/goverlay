# Spec Delta

## MODIFIED Requirements

### Requirement: OptiScaler Options Card Height Without Vertical Scrolling
The OptiScaler tab options card SHALL fit within standard application window dimensions without causing vertical scrolling on the tab scrollbox, hosting GPU Driver selection inside the "Main" sub-column.

#### Scenario: Standard Window Height Layout
- **GIVEN** GOverlay is opened at its default window dimensions (client height ~648px)
- **WHEN** the user navigates to the OptiScaler tab
- **THEN** `FOsOptionsCard` height SHALL be less than 410px and at least 290px
- **AND** `FOsBgPanel` height SHALL NOT exceed `FOsScrollBox.ClientHeight`
- **AND** `FOsStatusCard` bottom SHALL fit completely within `FOsScrollBox.ClientHeight` without vertical scrollbar activation

## ADDED Requirements

### Requirement: GPU Driver Selector in Options Main Column
The system SHALL provide a GPU Driver selection dropdown (`TComboBox`) within the "Main" sub-column of the Options card (`FOsMainSec`). Changing the dropdown selection SHALL update the active driver preference, synchronize dependent controls (such as DLSS spoofing and LatencyFlex/Reflex options), and persist the selection.

#### Scenario: User selects Mesa driver
- **WHEN** the user selects "Mesa (AMD / Intel)" from the GPU Driver dropdown
- **THEN** the system marks the Mesa preference as active, enables DLSS spoofing and Reflex/LatencyFlex options, and persists `mesa` to configuration.

#### Scenario: User selects NVIDIA driver
- **WHEN** the user selects "NVIDIA" from the GPU Driver dropdown
- **THEN** the system marks the NVIDIA preference as active, disables DLSS spoofing and LatencyFlex options, and persists `nvidia` to configuration.

#### Scenario: Auto-detection indicator on startup
- **GIVEN** GOverlay starts up and initializes the OptiScaler tab
- **WHEN** hardware detection identifies whether the NVIDIA kernel module is loaded
- **THEN** the GPU Driver dropdown displays the detected driver preference with an indication of auto-detection when no manual preference overrides it.
