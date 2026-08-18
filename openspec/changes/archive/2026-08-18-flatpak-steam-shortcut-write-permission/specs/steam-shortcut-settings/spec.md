# steam-shortcut-settings Specification (Delta)

## MODIFIED CAPABILITY
`steam-shortcut-settings`

## Requirements

### Requirement: Flatpak sandbox compatibility
The helper script SHALL detect if it is running within a Flatpak sandbox. If so, it SHALL configure the shortcut to launch via Flatpak rather than directly referencing the sandbox's internal binary path.
Furthermore, the Flatpak container configuration SHALL provide read-write filesystem access to native Steam data directories (`~/.local/share/Steam` and `~/.steam`) in addition to Flatpak Steam data directories (`~/.var/app/com.valvesoftware.Steam`).

#### Scenario: Creating shortcut under Flatpak for native Steam
- **WHEN** GOverlay runs inside a Flatpak environment and native Steam is installed on the host
- **THEN** GOverlay has write permissions to update `shortcuts.vdf` in `~/.local/share/Steam/userdata/*/config/` without encountering read-only permission errors.

### Requirement: Steam Userdata Path Discovery and Deduplication
The helper script SHALL discover all local Steam userdata directories and resolve symbolic links so that each unique physical `shortcuts.vdf` is processed exactly once.

#### Scenario: Resolving symlinked Steam folders
- **WHEN** Steam installations contain symlinked directories (such as `~/.steam/steam` or `~/.steam/root` pointing to `~/.local/share/Steam`)
- **THEN** the script resolves canonical paths via realpath and operates on each unique file without duplicate warnings or multiple write passes.
