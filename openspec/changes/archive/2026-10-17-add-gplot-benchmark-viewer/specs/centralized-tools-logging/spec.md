# Spec Delta

## ADDED Requirements

### Requirement: Per-game MangoHud benchmark CSV directory and auto-organization
The system SHALL configure the default MangoHud benchmark `output_folder` to `~/.local/share/goverlay/logs/<GameDirName>/` for active game profiles (or `~/.local/share/goverlay/logs/` in Global mode), ensure the target directory exists on disk, upgrade legacy `~/.local/share/goverlay` paths on profile load, and organize loose `<app>_YYYY-MM-DD_HH-MM-SS*.csv` benchmark files into `~/.local/share/goverlay/logs/<app>/`.

#### Scenario: Default MangoHud output_folder for a selected game profile
- **WHEN** the user selects a game profile (or resets MangoHud defaults while a game is active) and saves the configuration
- **THEN** `output_folder` in the game's `MangoHud.conf` points to `~/.local/share/goverlay/logs/<GameDirName>/` and the directory is created on disk if it does not already exist.

#### Scenario: Upgrading legacy root output_folder path
- **WHEN** an existing `MangoHud.conf` specifies the legacy default `output_folder=/home/<user>/.local/share/goverlay`
- **THEN** loading the profile upgrades `logfolderEdit` to `~/.local/share/goverlay/logs/<GameDirName>/` (for a game profile) or `~/.local/share/goverlay/logs/` (for the Global profile).

#### Scenario: Auto-organizing loose MangoHud CSV logs into game subdirectories
- **WHEN** loose MangoHud benchmark files such as `pascube_2026-10-17_14-07-18.csv` and `pascube_2026-10-17_14-07-18_summary.csv` exist directly in `~/.local/share/goverlay/` or `~/.local/share/goverlay/logs/`
- **THEN** GOverlay moves both files into `~/.local/share/goverlay/logs/pascube/` so they appear under the `pascube` game entry in GPLOT.
