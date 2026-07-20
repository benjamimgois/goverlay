## MODIFIED Requirements

### Requirement: Download and extract FakeNVAPI
GOverlay SHALL query the GitHub API to find the latest stable release tag of `fakenvapi`. It SHALL download the `.7z` release archive, extract it to the selected channel's cache folder, delete the downloaded archive, and add `FakeNvapiVersion=<version>` (without the 'v' prefix) to `goverlay.vars` inside the cache folder.

When updating the `FakeNvapiVersion` key in an existing `goverlay.vars`, the system SHALL match the key using a prefix copy of exactly 17 characters (`'fakenvapiversion='`) so that the existing line is correctly identified and updated in-place rather than a duplicate line being appended.

#### Scenario: FakeNVAPI installed and version tracked
- **WHEN** GOverlay updates or installs OptiScaler
- **THEN** GOverlay downloads and extracts the latest stable `fakenvapi` DLL and INI files to the cache folder, and writes `FakeNvapiVersion` to `goverlay.vars`.

#### Scenario: FakeNVAPI version key updated in-place
- **WHEN** GOverlay performs a second install or update and the `goverlay.vars` file already contains a `FakeNvapiVersion=<old>` line
- **THEN** GOverlay replaces that line in-place with the new version, and no duplicate `FakeNvapiVersion` line is added.

#### Scenario: FakeNVAPI version key removed on uninstall
- **WHEN** GOverlay uninstalls OptiScaler for a game or switches game context
- **THEN** the `FakeNvapiVersion` line is correctly removed from the game's `goverlay.vars` during cleanup.
