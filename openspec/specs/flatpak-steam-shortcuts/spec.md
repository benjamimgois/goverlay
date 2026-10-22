# Capability: flatpak-steam-shortcuts

## Purpose
Ensure compliant Flatpak sandbox security by using read-only Steam directory permissions, while providing clear user instructions for adding GOverlay to Steam on Steam Deck and Flatpak environments.

## Requirements

### Requirement: Read-Only Steam Directory Permissions in Flatpak Manifests
The Flatpak manifests MUST declare read-only permissions for Steam directories (`~/.local/share/Steam:ro`, `~/.steam:ro`, `~/.var/app/com.valvesoftware.Steam:ro`).

#### Scenario: Building and verifying Flatpak manifest finish-args
- **WHEN** the Flatpak manifest files are inspected
- **THEN** all Steam directory permissions specify `:ro` instead of `:rw`.

### Requirement: User Guidance Dialog in Flatpak Runtime
When running within a Flatpak sandbox and the user triggers Steam shortcut creation, the application MUST display an instructional dialog in English explaining how to add GOverlay to Steam via Desktop Mode.

#### Scenario: User clicks "Create Steam Shortcut" inside Flatpak
- **GIVEN** GOverlay is running inside a Flatpak sandbox (`IsRunningInFlatpak` is true)
- **WHEN** the user clicks "Create Steam Shortcut"
- **THEN** an informational dialog with Desktop Mode instructions is displayed
- **AND** the helper script is not executed and no filesystem writes to Steam directories are attempted.
