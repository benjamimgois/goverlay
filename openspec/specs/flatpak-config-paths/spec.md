# Flatpak Config Paths Support

## Purpose
Support resolving global configuration directories for MangoHud, vkBasalt, and vkSumi in Flatpak environment using environment variables.

## Requirements
### Requirement: Resolve config paths using environment variables
The system SHALL use `$HOST_XDG_CONFIG_HOME` or `$XDG_CONFIG_HOME` (in that order) to resolve global configuration directories for MangoHud, vkBasalt, and vkSumi when running inside Flatpak. The system SHALL NOT bypass `$XDG_CONFIG_HOME` check or hardcode the target config directory to `~/.config`. The system SHALL only fallback to `~/.config` if those environment variables are not set.

#### Scenario: Resolve MangoHud config dir inside Flatpak
- **WHEN** GOverlay runs inside Flatpak and `$XDG_CONFIG_HOME` is set to "/home/user/.var/app/io.github.benjamimgois.goverlay/config"
- **THEN** GetMangoHudConfigDir returns "/home/user/.var/app/io.github.benjamimgois.goverlay/config/MangoHud"

#### Scenario: Resolve vkBasalt config dir inside Flatpak
- **WHEN** GOverlay runs inside Flatpak and `$XDG_CONFIG_HOME` is set to "/home/user/.var/app/io.github.benjamimgois.goverlay/config"
- **THEN** GetVkBasaltConfigDir returns "/home/user/.var/app/io.github.benjamimgois.goverlay/config/vkBasalt"

#### Scenario: Resolve vkSumi config dir inside Flatpak
- **WHEN** GOverlay runs inside Flatpak and `$XDG_CONFIG_HOME` is set to "/home/user/.var/app/io.github.benjamimgois.goverlay/config"
- **THEN** GetVkSumiConfigDir returns "/home/user/.var/app/io.github.benjamimgois.goverlay/config/vkSumi"
