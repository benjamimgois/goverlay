## MODIFIED Requirements

### Requirement: Full Tag-Based Rolling Release Check
The system SHALL compare the full release `tag_name` from `bygalacos/OptiScalerBuilder` against the local release tag (`dlssenablertag` or `optiScalerVersion`) stored in `dlssenabler-stable/goverlay.vars` to detect rolling updates.

#### Scenario: Detecting newer DLSS Enabler release tag
- **WHEN** a new release tag is published on `bygalacos/OptiScalerBuilder`
- **AND** the remote tag does not match the local `dlssenablertag` in `goverlay.vars`
- **THEN** GOverlay detects the tag difference, updates the OptiScaler version label in Software Status, and reveals the Update button without displaying Toast notifications.

#### Scenario: Re-checking version after DLSS Enabler update
- **WHEN** DLSS Enabler is updated and `goverlay.vars` is updated with `dlssenablertag` matching the latest release tag
- **THEN** GOverlay SHALL hide the "Update Available" notification label and hide the Update button.
