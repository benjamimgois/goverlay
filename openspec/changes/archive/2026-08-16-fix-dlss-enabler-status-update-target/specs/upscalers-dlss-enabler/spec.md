# Capability: Upscalers Tab & DLSS Enabler Support

## MODIFIED Requirements

### Requirement: DLSS Enabler Update Status Display
When DLSS Enabler is enabled (`UPSCALER_TYPE=1` / `dlssenablerRadioButton.Checked = True`) and a newer DLSS Enabler release is available:
1. GOverlay SHALL display the update notification arrow and target version on the DLSS Enabler status row in the Software Status card (`<installed_version> → <new_version>` formatted with `CLR_UPDATE`).
2. GOverlay SHALL keep the OptiScaler status row displaying the installed OptiScaler version in standard purple color (`PURPLE`) without an update arrow.

When standard OptiScaler is selected (`optiscalerRadioButton.Checked = True`) and an OptiScaler update is available:
1. GOverlay SHALL display the update notification arrow on the OptiScaler status row (`<installed_version> → <new_version>` formatted with `CLR_UPDATE`).
2. The DLSS Enabler status row SHALL display `--`.

#### Scenario: DLSS Enabler update is available
- **WHEN** DLSS Enabler is selected (`dlssenablerRadioButton.Checked = True`)
- **AND** a newer version of DLSS Enabler is available from the remote repository (e.g. installed is `4.8.12` and latest is `4.8.13.19`)
- **THEN** the Software Status DLSS Enabler row displays `4.8.12 → 4.8.13.19` in update highlight color
- **AND** the Software Status OptiScaler row displays its installed version (e.g. `stable-0.9.4`) in standard color without an update arrow

#### Scenario: DLSS Enabler is up to date
- **WHEN** DLSS Enabler is selected (`dlssenablerRadioButton.Checked = True`)
- **AND** the installed DLSS Enabler version matches the latest remote release
- **THEN** the Software Status DLSS Enabler row displays its installed version in standard color without an update arrow
- **AND** the Software Status OptiScaler row displays its installed version in standard color without an update arrow
