## ADDED Requirements

### Requirement: gameconfig/global/ receives full OptiScaler assets on first run
When GOverlay auto-installs OptiScaler during the first run, the global profile configuration directory SHALL receive the downloaded OptiScaler runtime files so that it is a complete mirror of `~/.local/share/goverlay/bgmod/`.

#### Scenario: Auto-install on first run
- **WHEN** GOverlay auto-installs OptiScaler because `bgmod/` does not yet contain `OptiScaler.dll`
- **THEN** after the download and extraction finish, `~/.local/share/goverlay/gameconfig/global/` SHALL contain the same OptiScaler DLLs, plugins, and supporting libraries as `~/.local/share/goverlay/bgmod/`
