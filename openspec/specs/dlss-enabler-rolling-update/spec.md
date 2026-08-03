# Capability: DLSS Enabler Rolling Update

## Requirements

### Requirement: Full Tag-Based Rolling Release Check
The system SHALL compare the full release `tag_name` from `bygalacos/OptiScalerBuilder` against the local tag in `dlssenabler-stable/goverlay.vars` to detect rolling updates.

#### Scenario: Detecting newer DLSS Enabler release tag
- **WHEN** a new release tag is published on `bygalacos/OptiScalerBuilder`
- **THEN** GOverlay detects the tag difference, updates the OptiScaler version label in Software Status, and reveals the Update button without displaying Toast notifications.

### Requirement: User-Triggered Installation
The system SHALL download and install the new DLSS Enabler release package only when the user clicks the Update button.

#### Scenario: User clicks Update button
- **WHEN** the user clicks the Update button while DLSS Enabler update is available
- **THEN** GOverlay downloads the `.7z` asset, extracts it to `dlssenabler-stable/`, updates `goverlay.vars` with the new full release tag, refreshes UI labels instantly, and sets the status dot to green.
