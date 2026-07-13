## ADDED Requirements

### Requirement: Scan AppImage Executables
When GOverlay loads the list of non-Steam game folders, GOverlay SHALL scan for files with `.appimage` or `.AppImage` extensions in addition to subdirectories.

#### Scenario: AppImage File is Listed in Games Tab
- **WHEN** a non-Steam games directory contains the file `Dusklight-v1.4.1-linux-x86_64.appimage`
- **THEN** GOverlay detects this file and queues it to be listed as a game.

### Requirement: Normalize AppImage Game Names
GOverlay SHALL clean the AppImage filename by stripping the `.appimage`/`.AppImage` extension, common platform words (e.g., `linux`), architecture indicators (e.g., `x86_64`, `amd64`, `x64`), and trailing version numbers (preceded by `-v` or `-` followed by digits and dots) to obtain a clean, normalized game name.

#### Scenario: Cleaning Complex AppImage Filenames
- **WHEN** the filename is `Dusklight-v1.4.1-linux-x86_64.appimage`
- **THEN** the normalized game name is set to `Dusklight`.

#### Scenario: Cleaning Version Only AppImage Filenames
- **WHEN** the filename is `SuperGame-1.0.0.AppImage`
- **THEN** the normalized game name is set to `SuperGame`.

### Requirement: Tooltip Path Mapping
GOverlay SHALL set the mouse-hover tooltip hint of the game card panel to display the clean game name on the first line, followed by a line break, and the full absolute path to the `.appimage` file on the second line.

#### Scenario: Game Card Tooltip Verification
- **WHEN** the user hovers the cursor over the game card of a detected AppImage file
- **THEN** the card tooltip displays the game name and the full filepath of the AppImage file.
