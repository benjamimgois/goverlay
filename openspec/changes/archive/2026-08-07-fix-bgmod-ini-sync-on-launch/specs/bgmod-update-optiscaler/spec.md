# Capability Spec: bgmod INI File Synchronization

## Specification

### INI File Synchronization on Launch
- WHEN `bgmod` launches a game with OptiScaler enabled (`GOverlayOptiscaler = True`):
  - `bgmod` SHALL copy `OptiScaler.ini` from `ConfigDir` (`~/.local/share/goverlay/gameconfig/<game>/` or `gameconfig/global/`) into `GameDir` whenever `ConfigDir/OptiScaler.ini` exists.
  - `bgmod` SHALL copy `fakenvapi.ini` from `ConfigDir` into `GameDir` whenever `ConfigDir/fakenvapi.ini` exists.
  - `bgmod` MUST NOT overwrite `GameDir/OptiScaler.ini` with pristine cache templates prior to syncing from `ConfigDir`.
