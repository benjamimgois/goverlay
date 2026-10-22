# Spec Delta

## MODIFIED Requirements

### Requirement: Unified Software Status Card
The system SHALL render a Software Status card anchored at the bottom of the Lossless Scaling tab, displaying status dots, component names, and detected versions/paths for the active Lossless Scaling library, MAKO engine, lsfg-vk layer, and AFMF layer. All runtime update indicators and action buttons across these components SHALL strictly enforce semantic version comparison (`CompareVersions > 0`), displaying update prompts only when remote is strictly newer and suppressing downgrade actions when remote <= local.

#### Scenario: Viewing software status
- **WHEN** user views the Lossless Scaling tab
- **THEN** system renders green or red status dots for the active Lossless Scaling library (`lsfg-vk.dll` when lsfg-vk is selected, `Lossless.dll` when MAKO is selected), the installed MAKO engine (`libmako-render.so`), and the lsfg-vk Vulkan layer (`VkLayer_LSFGVK_frame_generation.json` with fallback to legacy layer manifests), displaying the appropriate library path with a Browse button and the installed/remote versions.

#### Scenario: Viewing software status with lsfg-vk selected
- **WHEN** user views the Lossless Scaling tab with interpolation method set to lsfg-vk
- **THEN** the Software Status card displays the path to `lsfg-vk.dll` with a Browse button and updates the status dot based on whether `lsfg-vk.dll` exists.

#### Scenario: Viewing software status with MAKO selected
- **WHEN** user views the Lossless Scaling tab with interpolation method set to MAKO
- **THEN** the Software Status card displays the path to `Lossless.dll` with a Browse button and updates the status dot based on whether `Lossless.dll` exists.

#### Scenario: Update check evaluates remote version older or equal to local
- **WHEN** an update check completes for any runtime component (MAKO, lsfg-vk, or AFMF) and remote version is less than or equal to local
- **THEN** system SHALL NOT display an update arrow (`→`) in the status card, SHALL NOT show "Install update", and SHALL keep the status label clean.
