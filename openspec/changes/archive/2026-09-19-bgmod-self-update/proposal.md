# Proposal

## Why

Currently, wrapper binaries (`bgmod`, `bgmod-uninstaller`, `bgmod-splash`) in existing per-game directories (`~/.local/share/goverlay/gameconfig/<Game>/`) are only synchronized when the GOverlay GUI is launched. However, many users configure GOverlay once and rarely reopen the GUI, launching games directly from Steam, Heroic, or Lutris. When GOverlay is updated via distro package managers (`pacman`, `apt`, `dnf`) or Flatpak (`flatpak update`), existing game wrappers remain on outdated versions indefinitely. Enabling `bgmod` to self-update during game launch ensures that all bug fixes, wrapper compatibility updates, and logging improvements are immediately available to every game without requiring users to open the GOverlay GUI.

## What Changes

- Implement runtime master binary discovery in `bgmod` that inspects system library directories (`/usr/libexec/goverlay/`, `/usr/lib/goverlay/`, `/usr/local/libexec/goverlay/`), Flatpak host locations (`/var/lib/flatpak/...`, `~/.local/share/flatpak/...`), and user template cache (`~/.local/share/goverlay/bgmod/`).
- Perform an atomic update of `bgmod`, `bgmod-uninstaller`, and `bgmod-splash` in the executing game profile directory when the master binary is newer or different from the local wrapper.
- Use Linux atomic replace (`.tmp` + `fpChmod` + `fpRename`) to prevent `ETXTBSY` ("Text file busy") errors when updating running binaries.
- Perform a seamless self re-execution (`fpexecv`) upon successful update, with recursion guard (`BGMOD_UPDATED=1`), ensuring the game launch immediately runs under the updated binary.
- Add an informational item (`"BGMod updated"`) to the `bgmod-splash` checklist when a self-update was performed on that launch, providing clear visual feedback in English.
- Log self-update events and outcomes in the central GOverlay log.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `game-wrapper-binary-sync`: Adds runtime self-update and atomic replacement of wrapper binaries (`bgmod`, `bgmod-uninstaller`, `bgmod-splash`) by `bgmod` during game launch, in addition to startup GUI synchronization.
- `bgmod-launch-splash`: Adds a "BGMod updated" notification item to the active splash screen checklist when a wrapper self-update occurs.

## Impact

- `bgmod.lpr`: Logic to discover master binary, compare file age/size, perform atomic file replacements, trigger re-execution, and pass update status to launch splash.
- `bgmod-uninstaller.lpr` / `bgmod_resources.pas`: Shared helper routines or consistent master discovery paths if needed.
- `tests/logic/logic_test_cases.pas`: Unit tests for binary comparison, master discovery paths, and self-update safety mechanisms.
