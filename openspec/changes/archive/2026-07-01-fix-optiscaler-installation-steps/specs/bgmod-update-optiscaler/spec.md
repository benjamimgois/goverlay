## ADDED Requirements

### Requirement: Move OptiScaler subfolder contents to root
After extracting the OptiScaler release archive to `.bgmod_original`, GOverlay SHALL check if an `OptiScaler` subfolder exists. If present, it SHALL recursively copy all files and directories inside `OptiScaler` to the root of `.bgmod_original` and then delete the `OptiScaler` subfolder.

#### Scenario: Subfolder contents moved to root during update
- **WHEN** OptiScaler is extracted to `.bgmod_original` and contains a subfolder named `OptiScaler`
- **THEN** GOverlay moves its contents to the root and deletes the `OptiScaler` subfolder.

### Requirement: Download frame generation helper
When installing or updating OptiScaler (both interactive and auto-install), GOverlay SHALL download `dlssg_to_fsr3_amd_is_better.dll` from the stable releases URL to `.bgmod_original`.

#### Scenario: Auxiliary DLL downloaded successfully
- **WHEN** GOverlay performs a manual or automatic OptiScaler installation
- **THEN** the auxiliary DLL `dlssg_to_fsr3_amd_is_better.dll` is downloaded to `.bgmod_original`.

### Requirement: Download and extract FakeNVAPI
GOverlay SHALL query the GitHub API to find the latest stable release tag of `fakenvapi`. It SHALL download the `.7z` release archive, extract it to `.bgmod_original`, delete the downloaded archive, and add `FakeNvapiVersion=<version>` (without the 'v' prefix) to `goverlay.vars`.

#### Scenario: FakeNVAPI installed and version tracked
- **WHEN** GOverlay updates or installs OptiScaler
- **THEN** GOverlay downloads and extracts the latest stable `fakenvapi` DLL and INI files, and writes `FakeNvapiVersion` to `goverlay.vars`.

### Requirement: Dynamic FSR and XeSS version resolution
During installation or update, GOverlay SHALL fetch `vars.txt` from the remote repository. It SHALL parse the FSR and XeSS version strings for both the stable and edge channels, and write the corresponding values as `fsrversion` and `xessversion` to `goverlay.vars` based on the selected channel.

#### Scenario: Versions retrieved and written to variables file
- **WHEN** GOverlay installs or updates OptiScaler on the stable or edge channel
- **THEN** it parses `vars.txt` and writes the correct `fsrversion` and `xessversion` keys to `goverlay.vars`.
