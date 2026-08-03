# Capability: OptiPatcher Rolling Update

## Requirements

### Requirement: Automatic Background Check on Tab Switch
The system SHALL check for OptiPatcher rolling release updates in the background whenever the user opens the OptiScaler tab.

#### Scenario: Switching to OptiScaler tab when a new OptiPatcher commit exists
- **WHEN** the user opens the OptiScaler tab
- **THEN** GOverlay asynchronously queries the OptiPatcher repository, detects the newer remote build date, downloads `OptiPatcher.asi`, updates all plugin directories, writes the new version to `goverlay.vars`, and updates the UI status label without locking the UI.

#### Scenario: Switching to OptiScaler tab when OptiPatcher is up to date
- **WHEN** the user opens the OptiScaler tab and local OptiPatcher date matches the remote release date
- **THEN** GOverlay completes the check silently without downloading files or modifying `goverlay.vars`.
