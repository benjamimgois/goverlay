## Context

GOverlay allows users to add non-Steam games by specifying directories containing executable files. The directories are saved in a text file named `nonsteam_folders.txt`. 

Currently, GOverlay hardcodes the path to this file:
`NonSteamFile := GetUserDir + '.config/goverlay/nonsteam_folders.txt';`

When running inside Flatpak, the host's `.config/` directory is not writable. Because GOverlay lacks permission to write to `~/.config/goverlay`, the application fails to save the file, causing non-Steam game cards to disappear upon restarting.

## Goals / Non-Goals

**Goals:**
- Fix the non-Steam game card persistence bug under the Flatpak sandbox.
- Use the central configuration path resolver (`TConfigManager.GetGoverlayFolder`) to handle GOverlay's internal configuration files.
- Maintain existing behavior for native (non-Flatpak) installations.

**Non-Goals:**
- Migrate data from host `~/.config/goverlay/nonsteam_folders.txt` into the sandbox, as this is typically inaccessible without external permissions.

## Decisions

### Decision 1: Use `TConfigManager.GetGoverlayFolder` in `games_tab.pas`

- **Approach**: Replace the hardcoded `GetUserDir + '.config/goverlay/'` path in `games_tab.pas` with `TConfigManager.GetGoverlayFolder`.
- **Alternatives Considered**: 
  - *Adding Flatpak permission `xdg-config/goverlay:create`*: This would grant write access to the host's `~/.config/goverlay`. However, it goes against sandboxing security best practices and requires changes to the packaging yml and flatpak permissions. Using GOverlay's sandboxed config folder is cleaner and safer.
- **Rationale**: `TConfigManager.GetGoverlayFolder` is Flatpak-aware. Under Flatpak, it returns `~/.var/app/io.github.benjamimgois.goverlay/config/goverlay/`, which is fully writable and persistent. Under native systems, it returns `~/.config/goverlay/`, preserving native behavior.

## Risks / Trade-offs

- **[Risk]**: If a user previously configured the Flatseal workaround (`xdg-config/goverlay:create`), their non-Steam game cards list is stored in the host's `~/.config/goverlay/nonsteam_folders.txt`. Since we are switching to GOverlay's sandboxed config folder, these cards will disappear when they update GOverlay and/or remove the Flatseal override.
- **[Mitigation]**: This workaround was not official. The UX improvement of not requiring manual Flatseal configuration outweighs the one-time loss of the non-Steam folders list. Users can easily re-add their non-Steam folders through GOverlay's interface, and the cards will now persist out-of-the-box.
