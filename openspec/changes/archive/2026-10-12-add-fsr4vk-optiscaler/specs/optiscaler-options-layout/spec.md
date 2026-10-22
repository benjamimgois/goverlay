# Spec Delta

## ADDED Requirements

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
