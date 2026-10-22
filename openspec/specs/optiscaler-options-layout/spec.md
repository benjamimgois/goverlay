# optiscaler-options-layout Specification

## Purpose
TBD - created by archiving change optiscaler-options-height. Update Purpose after archive.

## Requirements

### Requirement: OptiScaler Options Card Height Without Vertical Scrolling
The OptiScaler tab options card SHALL fit within standard application window dimensions without causing vertical scrolling on the tab scrollbox, hosting GPU Driver selection inside the "Main" sub-column.

#### Scenario: Standard Window Height Layout
- **GIVEN** GOverlay is opened at its default window dimensions (client height ~648px)
- **WHEN** the user navigates to the OptiScaler tab
- **THEN** `FOsOptionsCard` height SHALL be less than 410px and at least 290px
- **AND** `FOsBgPanel` height SHALL NOT exceed `FOsScrollBox.ClientHeight`
- **AND** `FOsStatusCard` bottom SHALL fit completely within `FOsScrollBox.ClientHeight` without vertical scrollbar activation

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

### Requirement: FSR4 Vulkan Shortcut Toggle
The system SHALL display an "FSR4 Vulkan" toggle switch within the "Spatial Upscaler" column of the OptiScaler tab that acts as a bidirectional shortcut to the "FSR4VK" software status channel.

#### Scenario: User toggles FSR4 Vulkan on
- **WHEN** user enables the "FSR4 Vulkan" toggle switch
- **THEN** the system stores the previous channel selection and switches the Software Status channel combobox to "FSR4VK".

#### Scenario: User toggles FSR4 Vulkan off
- **WHEN** user disables the "FSR4 Vulkan" toggle switch
- **THEN** the system switches the Software Status channel combobox back to the previously stored channel (e.g. "Stable Channel" or "Bleeding-edge").

#### Scenario: User changes channel combobox directly
- **WHEN** user changes the Software Status channel combobox directly to "FSR4VK"
- **THEN** the "FSR4 Vulkan" toggle switch turns on automatically.

#### Scenario: User switches away from FSR4VK in channel combobox
- **WHEN** user changes the Software Status channel combobox from "FSR4VK" to any other channel
- **THEN** the "FSR4 Vulkan" toggle switch turns off automatically.
