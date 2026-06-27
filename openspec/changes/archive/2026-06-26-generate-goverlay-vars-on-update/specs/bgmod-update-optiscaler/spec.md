## ADDED Requirements

### Requirement: Save OptiScaler version in manifest file during update
When GOverlay updates/installs OptiScaler, it SHALL write or update the `OptiScalerVersion` key in the `goverlay.vars` file with the version tag that was installed. The file SHALL be saved in both the pristine `.bgmod_original` folder and the global `bgmod` configuration folder.

#### Scenario: Installation generates correct version variable
- **WHEN** GOverlay successfully extracts OptiScaler release `0.9.3-0`
- **THEN** GOverlay writes `OptiScalerVersion=0.9.3-0` to the `goverlay.vars` file in both directories.
