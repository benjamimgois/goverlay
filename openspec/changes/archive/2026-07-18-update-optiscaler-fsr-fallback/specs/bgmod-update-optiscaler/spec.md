## MODIFIED Requirements

### Requirement: Dynamic FSR and XeSS version resolution
During installation or update, GOverlay SHALL fetch `vars.txt` from the remote repository. It SHALL parse the FSR and XeSS version strings for both the stable and edge channels, and write the corresponding values as `fsrversion` and `xessversion` to `goverlay.vars` based on the selected channel.

#### Scenario: Versions retrieved and written to variables file
- **WHEN** GOverlay installs or updates OptiScaler on the stable or edge channel
- **THEN** it parses `vars.txt` and writes the correct `fsrversion` and `xessversion` keys to `goverlay.vars`.

#### Scenario: Network failure during version resolution fallback to defaults
- **WHEN** the remote `vars.txt` file cannot be reached during installation or update
- **THEN** GOverlay SHALL fallback to using the default version `4.1.1` for FSR on the stable channel.
